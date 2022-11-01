//
//  DataDestruction.swift
//  Better Step
//
//  Created by Fritz Anderson on 10/20/22.
//

import Foundation

/*
// This is in the Extensions group because `Destroy` is a generic service like the Formatting extensions.

/// Example of applying handlers to `Destroy` notifications.
///
/// `Destroy` is an `OptionSet` that covers all permutations of what data should be destroyed in this application.
private
final class Destroyer {
    #warning("Why is “which” passed in as a compound?")
    private func addHandler(which: Destroy,
                            handler: @escaping ((Notification) -> Void)) {
        let dCenter = NotificationCenter.default
        let retval = dCenter.addObserver(
            forName: which.notificationID, object: nil, queue: .current, using: handler)
        notificationHandlers.append(retval)
    }


    var notificationHandlers: [NSObjectProtocol] = []

    /// Install `Notification` handlers for the
    init() {
        addHandler(which: .unsafeSubjectID) { _ in
            SubjectID.id = SubjectID.unSet
        }

        addHandler(which: .DASI) { _ in
            AppStorageKeys.temporaryDASIResults.eraseDefault()
            AppStorageKeys.collectedDASI.negate()
            AppStorageKeys.hasCompletedSurveys.negate()
            // TODO: There's no file yet
            #warning("Many files aren'r erased")
        }

        addHandler(which: .usability) { _ in
            AppStorageKeys.tempUsabilityIntsCSV.eraseDefault()
            AppStorageKeys.collectedFreehandU.negate()
            AppStorageKeys.collectedUsability.negate()
            AppStorageKeys.hasCompletedSurveys.negate()
        }

        addHandler(which: .walk) { _ in

            #warning("No deletion of walk files.")
            // Trace back from the IncomngAccelerometry output to find the files.

            print("destroying walk")
        }
    }
}
*/

// Determine whether to have a top-down ForceAppReversion
// ("App, reset!" -> "Walk, reset", ...)
// or a bottom-up, per-task reversion (static Destroy OptionSet
// ("Walk, reset!" + "DASI, reset!")
//
// WAIT! the only source of notifications is the .post() function.
//    Never mind (I hope).
#warning("Determine whether to destroy bottom-up (Destroy) or top-down (ForceAppReversion)")

/// An `OptionSet` that identifies  data sets that should to be removed when the `gear` toolbar item is tapped.
///
/// There are two kinds of target sets.
/// * **scalar** cases are discrete targets for deletion, like DASI.
/// * **compound** cases are consist of more than one scalar case. `firstRunData`, for instance, contains both DASI and the Usability surveys.
///
/// Sending `post()` to a scalar case of ``Destroy`` posts a single “`Notification_\(rawValue)`” to signal to clients that the data they manage should be deleted.  These will be for scalars only;` post()` breaks compunds to scalars; clients will never see notifications for compounds
///
/// _see_ ``Destroyer`` for an example.
/// - warning: `.unsafeSubjectID` and `unsafeAppStatus` should appeaar in that order at the ends of coumpounds if those are desired.
struct Destroy: OptionSet, RawRepresentable, Hashable {
/// `RawRepresentable` adoption
    let rawValue: Int
    /// `RawRepresentable` adoption
    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    // MARK: - Scalar tasks
    /// Remove all walk data (first and second). There is no cas in which only a single walk will be wound back.
    static let walk         : Destroy = .init(rawValue: 16)
    /// Remove results of the DASI survey
    static let DASI         : Destroy = .init(rawValue: 1)
    /// Remove results  (scalar and detail) of the usability survey
    static let usability    : Destroy = .init(rawValue: 2)

    /// The stored `SubjectID` string and nothing else, orphaning  collected data. Clients should use `.subject` instead.
    static let unsafeSubjectID: Destroy = .init(rawValue: 32768)

    /// Remove the `TopPhases` phase ID, and only that, orphaning the SubjectID and the collected data. Clients should use `.all` instead.
    static let unsafeAppState : Destroy = .init(rawValue: 65536)

    // MARK: Compound tasks
    /// Clear out  the elements of`.firstRunData`, then the `SubjectID`.
    static let firstRunData : Destroy = [.DASI, .usability]
    // ... plus walking
    /// _All_ data collected for this Subject, buit not the Subject itself.
    static let dataForSubject: Destroy = firstRunData.union([.walk])
    // ... plus the subject itself.
    static let subject      : Destroy = dataForSubject.union([.unsafeSubjectID])
    static let all          : Destroy = subject.union([.unsafeAppState])


    /// Both the DASI and usability surveys.

    /// The name of the notification assigned to this case
    var notificationID: Notification.Name {
        Notification.Name("Destroy_\(rawValue)")
    }

    /// For any `Destroy` object key, look up the scalar records to destroy.
    private static let compounds: [Destroy : [Destroy]] = {
        var retval: [Destroy : [Destroy]]
        retval = [
            /// Destroy of walk kills walk data only
            .walk : [.walk],

            /// Destroy of DASI kills DASI survey data only
            .DASI : [.DASI],

            /// Destroy of usability kills usability survey data only
            .usability: [.usability],

            /// Destroy of first-run data kills the surveys (DASI, usability) only
            .firstRunData:
                [.DASI, .usability],

            /// Destroy of data for subject kill surveys _and_ the walks.
            .dataForSubject: [.DASI, .usability, .walk],

            /// Invalidate (blank ATW) the subject-ID string.
            ///
            /// - note: This is “unsafe” because it just changes the string and orphans all the associated data.
                .unsafeSubjectID: [.unsafeSubjectID],

            /// Destroy of subject destroys surveys, walks, and subject ID
            ///
            /// - warning:In a compound task list,  `unsafeSubjectID` (if desired) must be added last, followed by `revertAppStatus` (if desired): Data deletion may depend on the existing app state and subject ID.

            .subject: [.DASI, .usability, .walk, .unsafeSubjectID],

            /// Destroy all of the `all` data; and set app status to .onboarding.
            .all: [.DASI, .usability, .walk, .unsafeSubjectID, .unsafeAppState]
        ]

        return retval
    }()

    /// Post notifications of all scalar deletions in the option set.
    func post() {
        let center = NotificationCenter.default
        guard let tasks = Self.compounds[self] else { fatalError() }
        for task: Destroy in tasks {
            #if DEBUG
            print("Sending Destroy", task)
            #endif
            center.post(name: task.notificationID, object: nil)
        }
    }

    // Do I want a Publisher?
    /// A Combine `Publisher` for triggered destroys. Not clear it's useful.
    var publisher: NotificationCenter.Publisher {
        NotificationCenter.default
            .publisher(for: self.notificationID)
    }
}

extension Destroy: CustomStringConvertible {
    private static let names: [Destroy:String] = [
        .walk           : "Walking",
        .DASI           : "DASI",
        .usability      : "Usability",
        .unsafeSubjectID: "UNSAFE SubjectID",
        .unsafeAppState : "UNSAFE App state",
        ]

    var description: String {
        if let primitiveName = Self.names[self] {
            return "Destroy \(primitiveName)"
        }
        else {
            return "Destroy ompound(\(self.rawValue))"
        }
    }
}
