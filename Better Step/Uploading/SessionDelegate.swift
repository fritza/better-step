//
//  SessionDelegate.swift
//  DataTaskMinimal
//
//  Created by Fritz Anderson on 1/29/23.
//

import Foundation

/// A `URLSessionDelegate` that accepts self-signed certificates from The University of Chicago.
public final class UpSessionDelegate: NSObject, URLSessionDelegate {
    
    /// The ID for background completion of uploads.
    ///  Unfortunately, these are not supported for task API
    ///  that takes completion closures.
    ///
    ///  I assume that includes the async APIs.
    public static let backgroundConfigID = "com.drdrlabs.betterstep.upload"
    
    /// Create a `URLSession` for uploads. Used only by `UpSessionDelegate.session`.
    ///
    /// The unique thing about this Session is that its delegate is a ``UpSessionDelegate``. In a better world, this Session would be prepped for background operation, but that has knock-on effects for completion handlers (can't be closures).
    ///
    /// - seealso: ``backgroundConfigID``.
    private static func instantiateSession() -> URLSession {
        let configuration =
        URLSessionConfiguration.default
        return URLSession(configuration: configuration,
                          delegate: UpSessionDelegate(),
                          delegateQueue: .main)
    }
    
    /// Singleton `URLSession` for uploads.
    ///
    /// Carries the `UpSessionDelegate` delegate, without polluting `URLSession.shared` for other clients.
    public static let session: URLSession = {
        return instantiateSession()
    }()
    
    /*
     /// `NSObject` subclassing; the compiler demanded an initializer.
     ///
     /// (I think the requirement is for ensuring `super.init()` is called. Swift automatic)
     //    override init() { }
     // NOTE: The error seems not to appear any more if I comment-out init().
     */
    
    /// Examine server-trust credentials that cover hosts in the `*.uchicago.edu` domain, and approve them all.
    ///
    /// Adoption of protocil `URLSessionDelegate`.
    /// - note: This may not be necessary now that `Info.plist, ` (key `NSAppTransportSecurity`) exempts `uchicago.edu` from Application Transport Security (ATS),
    /// - Parameters:
    ///   - session: The `URLSession` instance on which the challenge was raised.
    ///   - challenge: The specifics of the challenge to be evaluated.
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge) async
    -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        let proSpace = challenge.protectionSpace
        let method = proSpace.authenticationMethod
        
        guard method == NSURLAuthenticationMethodServerTrust,
              proSpace.host.isUChicagoHost,
              let serverTrust = proSpace.serverTrust else {
            return (.performDefaultHandling, nil)
        }
        guard challenge.previousFailureCount == 0 else {
            return (.cancelAuthenticationChallenge, nil)
        }
        
        let credential = URLCredential(trust: serverTrust)
        return (.useCredential, credential)
    }
}
