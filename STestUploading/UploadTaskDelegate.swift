import Foundation

let userID           = "iosuser"
let password         = "sliD3gtorydra"

// MD5 = `442e6161bee6c1178d94d30b67a663a0`

// MARK: - UploadTaskDelegate
public class UploadTaskDelegate: NSObject, URLSessionTaskDelegate {
    
    /// Shorthand for the callback method for receiving an authentication challenge.
    public typealias ChallengeCallback = (URLSession.AuthChallengeDisposition,
                                          URLCredential?) -> Void
    
    // MARK: - credential
    /// Permanent, re-usable credentials with the client-to-remote username and password for Basic authorization.
    private let credential = URLCredential(
        user        : userID,
        password    : password,
        persistence : .forSession)
    var credentialString: String {
        "CREDS: user: \(userID)\tpassword: \(password)"
    }
    
    
    /* Session-level */
    // `URLSessionTaskDelegate` adoption for authorization challenges.
    // MARK: - didReceive challenge
    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping ChallengeCallback) {
            let method = challenge.protectionSpace.authenticationMethod
            // Is this HTTP basic?
            guard method ==
                    NSURLAuthenticationMethodHTTPBasic
            else {
                // No.
                // Pass it along for someone else to handle.
                completionHandler(.performDefaultHandling, nil)
                return
            }
            
            guard challenge.previousFailureCount == 0 else {
                // Are they asking for a retry?
                // I don't do that, reject the challenge.
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }
            // … yes, use `self.credential` to supply username and password.
            completionHandler(.useCredential, credential)
        }
    
    // MARK: - didSendBodyData
    public func urlSession(_ session: URLSession, task: URLSessionTask,
                           didSendBodyData bytesSent: Int64,
                           totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        return
    }
    
    // MARK: - didComplete
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didCompleteWithError error: Error?) {
        print("DidCompplete hit with task,", error ?? "no error")
        
        if let error {
            print("Got an error. Client side:", error)
            if let htSession = task.response as? HTTPURLResponse {
                print("\tServer side:", htSession.statusCode)
            }
        }
        else {
            print("Finished, no error client side. ")
        }
    }
}

