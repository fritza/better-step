//
//  SubjectID.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/28/22.
//

import Foundation

struct SubjectID {
    static let unSet = ""
    static var id: String {
        get {
            if let fromStore = UserDefaults.standard
                .string(forKey: ASKeys.subjectID.rawValue)
            {
                return fromStore
            }
            else {
                return Self.unSet
            }
        }
        set {
            if notificationTicket == nil { handleUserIDNotice() }
            UserDefaults.standard.set(newValue, forKey: ASKeys.subjectID.rawValue)
        }
    }

    static func validate(string: String) -> String {
        let desiredCharacters = CharacterSet.whitespacesAndNewlines.inverted
        let scanner = Scanner(string: id)
        let trimmed = scanner.scanCharacters(from: desiredCharacters)

        if let trimmed, !trimmed.isEmpty {
            return trimmed
        }
        else { return SubjectID.unSet }
    }

    static var validated: String {
        return validate(string: id)
    }

    static var notificationTicket: NSObjectProtocol?

    /// Set up a `Notification` handler for `Destroy.unsafeSubjectID`, deleting the subject ID string _and only that,_ from `UserDefaults`.
    static func handleUserIDNotice() {
        let dCenter = NotificationCenter.default
        notificationTicket = dCenter.addObserver(
            forName: Destroy.unsafeSubjectID.notificationID,
            object: nil, queue: .current) {
                _ in
                SubjectID.id = Self.unSet
            }
    }
}


final class NotificationSetup: ObservableObject {
    init() {
        clearDataNotices = Self.catchClearFirstRun()
    }
    
    /// Hold on to the notification handlers for (fist-run datum) -> destroy
    var clearDataNotices: [NSObjectProtocol]!

    static func catchClearFirstRun() -> [NSObjectProtocol] {
        var accum: [NSObjectProtocol] = []
        let dCenter = NotificationCenter.default

        // TODO: Should I set hasCompletedSurveys if the walk is negated?
        let ofConcern = [
            Destroy.DASI, Destroy.usability,
            //Destroy.walk
        ]
        for message in ofConcern {
            let catcher = dCenter
                .addObserver(
                    forName: message.notificationID,
                    object: nil,
                    queue: .current) {_ in
                        UserDefaults.standard
                            .set(false, forKey: ASKeys.hasCompletedSurveys.rawValue)
                    }
            accum.append(catcher)
        }
        return accum
    }
}
