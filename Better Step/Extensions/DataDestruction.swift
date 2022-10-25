//
//  DataDestruction.swift
//  Better Step
//
//  Created by Fritz Anderson on 10/20/22.
//

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

    init() {
        addHandler(which: .unsafeSubjectID) { _ in
            print("destroying subject ID")
        }

        addHandler(which: .DASI) { _ in
            print("destroying DASI")
        }

        addHandler(which: .usability) { _ in
            print("destroying usability")
        }

        addHandler(which: .walk) { _ in
            print("destroying walk")
        }
    }
}

/// An `OptionSet` that identifies  data sets that should to be removed when the `gear` toolbar item is tapped.
///
/// Sending `post()` to an instance of `Destroy` sends a notification that that class of data is to be removed, so the user can restore first-run behavior.
/// Some cases are compound: `.firstRunData`, for intance is _both_ `.DASI` and `.usability` When posted, the `NotificationCenter` will send the two out separately.
///
/// _see_ ``Destroyer`` in this source file for an example.
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
            // Destroy of walk kills walk data only
            .walk : [.walk],
            .unsafeSubjectID: [.unsafeSubjectID],
            // Destroy of DASI kills DASI survey data only
            .DASI : [.DASI],
            // Destroy of usability kills usability survey data only
            .usability: [.usability],
            // Destroy of first-run data kills the surveys only
            .firstRunData:
                [.DASI, .usability],

            // Destroy of data for subject kill surveys _and_ the walks.
            .dataForSubject: [.DASI, .usability, .walk],
            // Destroy of subject destroys surveys, walks, and subject ID
            // IMPORTANT: .unsafeSubjectID must be the last element.
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
}
