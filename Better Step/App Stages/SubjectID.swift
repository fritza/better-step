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
                .string(forKey: AppStorageKeys.subjectID.rawValue)
            {
                return fromStore
            }
            else {
                return ""
            }
        }
        set {
            if notificationTicket == nil { catchClearNotifications() }
            UserDefaults.standard.set(newValue, forKey: AppStorageKeys.subjectID.rawValue)
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
    static func catchClearNotifications() {
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

        // TODO: Should I set hasNeverCompleted if the walk is negated?
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
                            .set(true, forKey: AppStorageKeys.hasNeverCompleted.rawValue)
                    }
            accum.append(catcher)
        }
        return accum
    }
}
