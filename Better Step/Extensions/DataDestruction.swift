//
//  DataDestruction.swift
//  Better Step
//
//  Created by Fritz Anderson on 10/20/22.
//


#error("Rewind the app to the start")

import Foundation

// This is in the Extensions group because `Destroy` is a generic service like the Formatting extensions.

/// Example of applying handlers to `Destroy` notifications.
///
/// `Destroy` is an `OptionSet` that covers all permutations of what data should be destroyed in this application.
private
final class Destroyer {
    func addHandler(which: Destroy,
                    handler: @escaping ((Notification) -> Void)) {
        let dCenter = NotificationCenter.default
        let retval = dCenter.addObserver(forName: which.notificationID, object: nil, queue: .current, using: handler)
        notificationHandlers.append(retval)
    }


    var notificationHandlers: [NSObjectProtocol] = []

    /// Install `Notification` handlers for scalar ``Destroy`` cases.
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

/// An `OptionSet` that identifies  data sets that should to be removed when the `gear` toolbar item is tapped.
///
/// There are two kinds of target sets.
/// * **scalar** cases are discrete targets for deletion, like DASI.
/// * **compound** cases are consist of more than one scalar case. `firstRunData`, for instance, contains both DASI and the Usability surveys.
///
/// Sending `post()` to a scalar case of ``Destroy`` posts a single `Notification` that that particular record is to be removed. Compund vases run through the component cases one by one.
///
/// _see_ ``Destroyer`` for an example.
/// - warning: Maintainers who want to add or edit cases of `Destroy` _must_ make sure that `.unsafeSubjectID` comes last wherever it is used.
struct Destroy: OptionSet, RawRepresentable, Hashable {
/// `RawRepresentable` adoption
    let rawValue: Int
    /// `RawRepresentable` adoption
    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    // MARK: Scalar tasks
    /// Remove all walk data (first and second). There is no cas in which only a single walk will be wound back.
    static let walk         : Destroy = .init(rawValue: 16)
    /// Remove results of the DASI survey
    static let DASI         : Destroy = .init(rawValue: 1)
    /// Remove results  (scalar and detail) of the usability survey
    static let usability    : Destroy = .init(rawValue: 2)
    /// The `SubjectID` as just that `String`. client code should use `.subject`
    static let unsafeSubjectID: Destroy = .init(rawValue: 32768)

    // MARK: Compound tasks
    /// Clear out  the elements of`.firstRunData`, then the `SubjectID`.
    static let firstRunData : Destroy = [.DASI, .usability]
    // ... plus walking
    /// _All_ data collected for this Subject, buit not the Subject itself.
    static let dataForSubject: Destroy = firstRunData.union([.walk])
    // ... plus the subject itself.
    static let subject      : Destroy = dataForSubject.union([.unsafeSubjectID])

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
            ///
            /// - warning: In composing task rosters (as for `.subject`, `unsafeSubjectID` must appear _last,_ because data deletion may depend on having reference to the ID.
                .unsafeSubjectID: [.unsafeSubjectID],

            /// Destroy of subject destroys surveys, walks, and subject ID
            .subject: [.DASI, .usability, .walk, .unsafeSubjectID]
        ]

        return retval
    }()

    /// Post notifications of all scalar deletions in the option set.
    func post() {
        let center = NotificationCenter.default
        guard let tasks = Self.compounds[self] else { fatalError() }
        for task: Destroy in tasks {
            center.post(name: task.notificationID, object: nil)
        }
    }

    // Do I want a Publisher?
    /// A Combine `Publisher` for triggered destroys. Not clear it's useful.
    var publisher: NotificationCenter.Publisher {
        NotificationCenter.default
            .publisher(for: self.notificationID)
    }

    static func rewindTheApp() {
        //
    }
}
