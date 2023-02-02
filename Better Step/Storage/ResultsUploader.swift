//
//  ResultsUploader.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/1/22.
//

import Foundation
import SwiftUI  // FIXME: This is just to get @AppStorage.
// Switch it to UserDefaults and remove the dependency.

// MARK: - UploadCreds
// TODO: Make UploadCreds decodable
//       or at least a common source file
public enum UploadCreds {
    static let methodName = "POST"
    
#if API_DEV
    // Use for internal test and development
    static let lastPassName     = "Step Test Files API (dev and stage)"
    static let hostString       = "https://steptestfilesdev.uchicago.edu"
    static let userID           = "iosuser"
    static let password         = "sliD3gtorydra"
    //    static let password         = "Daf4Df24fshfg"
    //    rneA0drinnita
    
#elseif BETA_API
    // Use for TestFlight
    static let lastPassName     = "Step Test Files API (dev and stage)"
    static let hostString       = "https://steptestfilesstage.uchicago.edu"
    static let userID           = "iosuser"
    static let password         = "sliD3gtorydra"
    //    static let password         = "Daf4Df24fshfg"
#else
    // Public-release (production server)
    static let lastPassName     = "Step Test Files API (PROD)"
    static let hostString       = "https://steptestfiles.uchicago.edu"
    static let userID           = "iosuser"
    static let password         = "yliA7asthwone"
    //    static let password         = "#jd89DFa882%"
#endif
    static let uploadURL    = URL(string: hostString)!

    static let reviewPage   = "https://ios-s3-apidev.uchicago.edu/files/"
    static let reviewURL    = URL(fileURLWithPath: reviewPage)
}

typealias UploadFinish = (Bool) -> Void

// MARK: - ResultsUploader

/// Upload local data provided by a `file:///` `URL` to a particular server, ATW the Better Step database.
///
/// Credentials and remotes are drawn from ``UploadCreds``
/// - warning: This code is _not_ safe against interruptions from sleep or relaunch. A `
public class ResultsUploader // : Hashable
{
    /*
     Let’s talk about object lifetime.

     The creator will have a reference, but not after the assignment from init ends.
     The notification center will have a reference to the handlers, which the uploader holds for itself.
        REFERENCE CYCLE.
     The delegate has no apparent reference to this object.
     The completion callback self-refers
     The notification handlers, as written, self-refer.
     */

    // FIXME: Must retain this instance while it's active.

    /// The `URLSession` to generate the upload request and handle the `URLSessonDelegate`'s authentication callback.
    private let session = URLSession.shared
    private let dataRequest: URLRequest

    /// A **file** URL providing the data to be uploaded,
    private let dataURL: URL

    private var networkCompletion: UploadFinish
    /// Prepare an upload from a local file
    /// - Parameter url: The `URL` of the file whose contents are to be uploaded.
    init(fromLocalURL url: URL,
         completion: @escaping UploadFinish) throws {
        networkCompletion = completion
        self.dataURL = url
        let payload = try Data(contentsOf: url)
        if payload.isEmpty {
            throw FileStorageErrors.uploadEmptyData(url.path)
        }

        let urlForRemoteFile = UploadCreds
            .uploadURL
            .appending(component: url.lastPathComponent)
        // Form the request
        var request = URLRequest(url: urlForRemoteFile)
        request.httpBody = payload
        request.httpMethod = UploadCreds.methodName
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
//        func multipartParameter() -> String {
//            
//        }
        
        dataRequest = request
    }


    
    /// Set up the data task for the upload, and its delegate. Commence the upload.
    func proceed() {
        let destination = UploadCreds.uploadURL
        let upTask = session.dataTask(
            with: dataRequest, completionHandler: resultFunction)
        upTask.delegate = UploadTaskDelegate()
        upTask.resume()
        
        /*
         func proceed() {
         let task = session.dataTask(
         with: UploadServerCreds.uploadURL, completionHandler: resultFunction)
         task.delegate = UploadTaskDelegate()
         task.resume()
         }
         */

    }

    /// Completion code for the `POST`, as specified for ``URLSessionDataTask``.
    fileprivate func resultFunction(data: Data?,
                                    response: URLResponse?,
                                    error: Error?) {
        // Any error means not deleting the .zip file.
        // ON RETRY: We have a sync problem.
        guard
            let response = response as? HTTPURLResponse,
            !(200..<300).contains(response.statusCode)
        else {
            print("Upload request failed: \(error!.localizedDescription)")
            networkCompletion(false)
            return
        }

        // By here, the source file is away.
        // Tell the parent PhaseStorage
        // it can reset to the no-data-collected
        // state.
            networkCompletion(true)
    }
}



// MARK: - UploadTaskDelegate
///
/// ATW, the only function is to carrry out the client side of credential exchange via ``urlSession(_:task:didReceive:completionHandler:)``
/// - todo: Use a dedicated `URLSession`.
public class UploadTaskDelegate: NSObject, URLSessionTaskDelegate {

    /// Shorthand for the callback method for receiving an authentication challenge.
    public typealias ChallengeCallback = (URLSession.AuthChallengeDisposition,
                                          URLCredential?) -> Void

    /// Permanent, re-usable credentials with the client-to-remote username and password for Basic authorization.
    private let credential = URLCredential(
        user        : UploadCreds.userID,
        password    : UploadCreds.password,
        persistence : .forSession)
    
    /// `URLSessionTaskDelegate` adoption for authorization challenges.
    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping ChallengeCallback) {
            let method = challenge.protectionSpace.authenticationMethod
        // Is the server asking for Basic authentication?
        guard method == NSURLAuthenticationMethodHTTPBasic else {
            // … no, pass it along to whomever might be interested
            completionHandler(.performDefaultHandling, nil)
            return
        }
        // … yes, use `self.credential` to supply username and password.
        completionHandler(.useCredential, credential)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        print("upload: \(totalBytesSent)/\(totalBytesExpectedToSend)")
    }

    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didCompleteWithError error: Error?) {
        if let error {
            print("Got an error. Client side:", error)
            if let htSession = task.response as? HTTPURLResponse {
                print("\tServer side:", htSession.statusCode)
            }
        }
        else {
            print("Completed!")
        }
    }
}

// MARK: userInfo keys
enum UploadResultKeys: String, Hashable {
    case fileNameKey
    case serverNameKey

    case errorKey
}

/*
// MARK: Firing the notification
extension ResultsUploader {
    /// Broadcast the completion (successful or not) of the upload through `NotificationCenter`
    ///
    /// ATW, the available names are ``UploadFailedNotification`` and ``UploadCompleteNotification``.
    /// Also ATW, these notifications aren't used, but it seems likely they will be.
    func sendUploadNotice(name  : Notification.Name,
                          server: String,
                          error : Error? = nil) {
        var userInfo: [UploadResultKeys: Any] = [
            .fileNameKey  : name,
            .serverNameKey: server]
        if let error {
            userInfo[.errorKey] = error
        }

        let notice = Notification(name: name, object: self, userInfo: userInfo)
        NotificationCenter.default.post(notice)
    }
}
*/
