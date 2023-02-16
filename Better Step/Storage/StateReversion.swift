//
//  StateReversion.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/21/22.
//

import Foundation

/*
 What I'd like to see
 There's a lot of dependency in reversion on SubjectID.id.
 
 
 */



public let RevertAllNotice = Notification.Name(rawValue: "RevertAllNotice")

// Is there some protocol I can make to regularize registration and handling of the RevertAllNotice notification?

/// Adopters respond to a `Notification` calling for total reversion of app state.
///
/// “Total reversion” means ensuring that all state — file, memory, `UserDefaults`, UI — is as though the app had never been run. This exposes the onboarding and survey phases that are awailable only upon first run.
///
/// The expected trigger for total reversion is a trailing nav-bar button (atw SF Symbol “gear”).
/// - note: Neither the control not the process is to be exposed to subject users in production. It is solely for beta testing: Otherwise a tester would be able to exercise first run only by deleting and reinstalling the app.
protocol MassDiscardable {
    /// The closure adopters must call to report completion of their part of the process.
    typealias ReversionCompleted = (SeriesTag, Bool) -> Void
    
    /// Storage for the adopting object's notification handler so it doesn't get released.
    ///
    /// Adopter must declare the storage; ``installDiscardable()`` initializes it.
    var reversionHandler: AnyObject? { get set }
    
    func handleReversion(notice: Notification)
//    var  reversionComplete: ReversionCompleted { get set }
}

extension MassDiscardable {
    // I REALLY hope there are no dependencies among reversions
    /// The receiver for the app-wide `RevertAllNotice` The completion action calls the adopter's `handleReversion(notice:)` function.
    /// - returns: The `NotificationCenter` token for the handler code.
    /// - note: “install” is probably a misnomer. It is the caller that registers the completion handle.
    @discardableResult
    func installDiscardable() -> AnyObject? {
        // FIXME: Is this obsolete?
        let handle = NotificationCenter.default
            .addObserver(forName: RevertAllNotice,
                         object: nil, queue: nil,
                         using: handleReversion(notice:))
        return handle
    }
}

