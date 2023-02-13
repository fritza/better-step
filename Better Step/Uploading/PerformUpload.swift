//
//  PerformUpload.swift
//  DataTaskMinimal
//
//  Created by Fritz Anderson on 1/25/23.
//

import Foundation

public struct PerformUpload {
    
    typealias URLCallback = (Data?, URLResponse?, Error?) -> Void
    
    let payload: Data
    let fileName: String
    
    /// Create a manager for formatting and uploading the given payload data, into a server file with the given name
    /// - parameters:
    ///   - payload: The data to upload
    ///   - name:  The remote file name
    public init(for payload: Data, named name: String) {
        self.payload  = payload
        self.fileName = name
        self.payloadURL = nil
    }
    
    let payloadURL: URL?
    
    /// Create a manager for formatting and uploading data from a `URL`, into a server file with the given name
    /// - parameters:
    ///   - zipURL: A `URL` for a file containing data to upload.
    ///   - name:  The remote file name
    /// - returns: `nil` if the `Data` load fails or is empty.
    /// - bug: The initializer should throw.
    public init?(from zipURL: URL, named name: String) {
        do {
            let data = try Data(contentsOf: zipURL)
            if data.isEmpty { throw SimpleErrors.urlError(zipURL) }
            self.init(for: data, named: name)
        }
        catch {
            return nil
        }
    }
    
    /// Form a `URLRequest` from the known upload URL and a boundary string generated by the caller.
    ///
    /// Adds the root `Content-Type` to the request.
    func createRequest(boundaryString: String) -> URLRequest {
        
        assert(UploadCreds.uploadDirURL.absoluteString == UploadCreds.fullUploadString)
        
        var retval = URLRequest(
            url: UploadCreds.uploadDirURL,
            cachePolicy: .reloadIgnoringLocalCacheData)
        retval.setValue(
            "multipart/form-data; boundary=\(boundaryString)",
            forHTTPHeaderField: "Content-Type")
        retval.httpMethod = UploadCreds.method
        return retval
    }
    
    /// For the multipart data upload:
    ///
    /// * `Content-Type` header is form-data, with boundary ID = "Boundary-{UUID}", goes in the request. See ``createRequest(boundaryString:)``
    /// * Forms the payload multipart in ``multipartData(fileName:content:boundary:)``
    /// * Spawns a `Task` to perform the asynchronoous upload.
    ///
    /// Completion of the upload will trigger an `UploadNotification` notification.
    public func doIt() {
        // URLRequest including the boundary string.
        let boundary = "Boundary-\(UUID().uuidString)"
        let request = createRequest(boundaryString: boundary)
        
        // Wrap the payload in a multopart envelope
        let toTransfer: Data =
        try! multipartData(fileName: fileName,
                           content : payload,
                           boundary: boundary)
        
        Task {
            do {
                // Start/complete the upload asynchronously
                let (data, response) =
                try await UpSessionDelegate.session
                    .upload(for: request,
                            from: toTransfer,
                            delegate: UploadTaskDelegate())
                
                // Send `UploadNotification` to broadcast completion
                let userInfo: [String:Any] =
                ["response": response]
                NotificationCenter.default
                    .post(name: UploadNotification,
                          object: data,
                          userInfo: userInfo)
            }
            catch {
                // This is a system-level error.
                // Notify a .failure
                
                NotificationCenter.default
                    .post(name: UploadErrorNotification,
                          object: error)
                
                print("alternateUpload error:", error)
                print("I think I simply ignore it.")
            }
        }
    }
}
