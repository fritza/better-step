//
//  ResultsUploader.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/1/22.
//

import Foundation
import SwiftUI  // FIXME: This is just to get @AppStorage.
// Switch it to UserDefaults and remove the dependency.

// MARK: - UploadServerCreds
public enum UploadServerCreds {

    static let methodName = "POST"

#if API_DEV
    // Use for internal test and development
    static let lastPassName = "ios-s3-apidev"
    static let uploadString = "https://ios-s3-apidev.uchicago.edu/api/upload"
    static let userID       = "iosuser"
    static let password     = "Daf4Df24fshfg"
#elseif BETA_API
    // Use for TestFlight
    static let lastPassName = "ios-s3-apistage"
    static let uploadString = "https://ios-s3-apistage.uchicago.edu/api/upload"
    static let userID       = "iosuser"
    static let password     = "Daf4Df24fshfg"
#else
    // Public-release (production server)
    static let lastPassName = "ios-s3-api.uchicago.edu (PROD)"
    static let uploadString = "https://ios-s3-api.uchicago.edu/api/upload"
    static let userID       = "iosuser"
    static let password     = "#jd89DFa882%"
#endif
    static let uploadURL    = URL(string: uploadString)!

    static let reviewPage   = "https://ios-s3-apidev.uchicago.edu/files/"
    static let reviewURL    = URL(fileURLWithPath: reviewPage)
}

// MARK: - ResultsUploader

/// Upload local data provided by a `file:///` URL to a particular server, ATW the Better Step database.
///
/// Credentials and remotes are drawn from ``UploadServerCreds``

public class ResultsUploader // : Hashable
{
    @AppStorage(ASKeys.completedFirstRun.rawValue) var completedFirstRun = false
    
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

    // let uploadPayload: Data
    // Is this needed beyond init(payload:)?

    private let notificationHandlers: [AnyObject?]

    init(from url: URL) throws {
        dataURL = url
        let payload = try Data(contentsOf: url)
        if payload.isEmpty {
            throw FileStorageErrors.uploadEmptyData(url.path)
        }

        // Formulate the request
        var request = URLRequest(
            url: UploadServerCreds.uploadURL,
            timeoutInterval: TimeInterval.infinity)
        request.httpMethod = UploadServerCreds.methodName
        request.httpBody = payload
        dataRequest = request

        let nGood = NotificationCenter.default
            .addObserver(forName: UploadCompleteNotification, object: nil, queue: .main) { notice in
                print(#function, "received a notification named \(notice.name.rawValue)")
            }
        let nBad = NotificationCenter.default
            .addObserver(forName: UploadFailedNotification, object: nil, queue: .main) { notice in
                print(#function, "received a notification named \(notice.name.rawValue)")

//                Self.uploaders.remove(self)
            }
        notificationHandlers = [nGood, nBad]
    }

    /// Set up the data task for the upload, and its delegate. Commence the upload.
    func proceed() {
        let task = session.dataTask(
            with: UploadServerCreds.uploadURL, completionHandler: resultFunction)
        task.delegate = UploadTaskDelegate()
        task.resume()
    }

    /// Completion code for the `POST`, as specified for ``URLSessionDataTask``.
    fileprivate func resultFunction(data: Data?,
                                    response: URLResponse?,
                                    error: Error?) {
        
        #warning("Consider Combine for this. Consider making sense of this.")
        
        // Any error means not deleting the .zip file.
        // ON RETRY: We have a sync problem.
        guard
            let response = response as? HTTPURLResponse,
            !(200..<300).contains(response.statusCode)
        else {
            print("Upload request failed: \(error!.localizedDescription)")
            sendUploadNotice(name: UploadFailedNotification,
                             server: UploadServerCreds.uploadURL.absoluteString)
            return
        }

        // By here, the source file is away. Delete it.
        do {
            try FileManager.default
                .deleteIfPresent(dataURL)
            completedFirstRun = true
            sendUploadNotice(name: UploadCompleteNotification,
                             server: UploadServerCreds.uploadString)
        }
        catch {
            print("Can't delete", dataURL.path, "error =", error.localizedDescription)
            sendUploadNotice(name: UploadFailedNotification,
                             server: UploadServerCreds.uploadString, error: error)
            return
        }
    }
}



// MARK: - SessionTaskUploadWalkSession Task dUploadWalkSessionile-upload transactions.
///
/// ATW, the only function is to carrry out the client side of credential exchange via ``urlSession(_:task:didReceive:completionHandler:)``
/// - todo: Use a dedicated `URLSession`.
public class UploadTaskDelegate: NSObject, URLSessionTaskDelegate {

    /// Shorthand for the callback method for receiving an authentication challenge.
    public typealias ChallengeCallback = (URLSession.AuthChallengeDisposition,
                                          URLCredential?) -> Void

    /// Permanent, re-usable credentials with the client-to-remote username and password for Basic authorization.
    public let credential = URLCredential(
        user        : UploadServerCreds.userID,
        password    : UploadServerCreds.password,
        persistence : .forSession)

    /// `URLSessionTaskDelegate` adoption for authorization challenges.
    public func urlSession(_ session: URLSession,
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
}

// MARK: - Notification

// MARK: Names
let UploadCompleteNotification = Notification.Name(rawValue: "UploadNotification")
let UploadFailedNotification   = Notification.Name(rawValue: "UploadFailedNotification")

// MARK: userInfo keys

enum UploadResultKeys: String, Hashable {
    case fileNameKey
    case serverNameKey

    case errorKey
}

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

