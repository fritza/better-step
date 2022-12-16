//
//  SubjectID.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/28/22.
//

import Foundation

/// A unique identifier, assigned by the study, for the user and her data. It does _not_ adopt `Identifiable`.
///
/// The identifier itself is just a `String`. but this type validates it and handles `Destroy` `Notification`s to restore the ID to `unset`. A special in-band value for no-known-ID instead of `nil` is to make it easier to initialize `UserDefaults`.
/// - note: All methods are `static` — `SubjectID` wraps a singleton `String`.
/// - warning: Always use `unset` (atw an empty `String`) to indicate the absence of any known `SubjectID`.
struct SubjectID {
    init() {
        // FIXME: No idea how and where to receive deletion calls for unsafe SubjectID deletion.
        if SubjectID.notificationTicket == nil {
            Self.handleUserIDNotice()
        }
    }
    /// The `String` value indicating no valid contents.
    static let unSet = ""
    /// The `String` value of the ID.
    static var id: String {
        get {
            if let fromStore = UserDefaults.standard
                .string(forKey: ASKeys.subjectID.rawValue)
            {
                return fromStore
            }
            else {
                UserDefaults.standard
                    .set(Self.unSet, forKey: ASKeys.subjectID.rawValue)
//                    .set(Self.unSet, forkey)
                return Self.unSet
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ASKeys.subjectID.rawValue)
        }
    }

    /// Validate a `String` as suitable for use as a `SubjectID`
    /// - Parameter string: The `String` to validate
    /// - Returns: `string`, trimmed of  leading and trailing whitespace. If the result is empty, return `.unset`
    static func validate(string: String) -> String {
        let desiredCharacters = CharacterSet.whitespacesAndNewlines.inverted
        let scanner = Scanner(string: id)
        let trimmed = scanner.scanCharacters(from: desiredCharacters)

        if let trimmed, !trimmed.isEmpty {
            return trimmed
        }
        else { return SubjectID.unSet }
    }

    /// The ID value, passed through the static validate(string:) function.
    /// The result is "validated" in the sense that it has been stripped of whitespace — _made_ valid.
    static var validated: String {
        return validate(string: id)
    }

    // MARK:  Notifications
    private static var notificationTicket: NSObjectProtocol?
    = {
        let dCenter = NotificationCenter.default
        let noticeID = Destroy.unsafeSubjectID.notificationID
        let noticeString = noticeID.rawValue
        let retval = dCenter.addObserver(
            forName: Destroy.unsafeSubjectID.notificationID,
            object: nil, queue: .current) {
                _ in
                SubjectID.id = Self.unSet
            }
        return retval
    }()

    /// Set up a `Notification` handler for `Destroy.unsafeSubjectID`, deleting the subject ID string _and only that,_ from `UserDefaults`.
    static func handleUserIDNotice() {
        let dCenter = NotificationCenter.default
        let noticeID = Destroy.unsafeSubjectID.notificationID
        let noticeString = noticeID.rawValue
        notificationTicket = dCenter.addObserver(
            forName: Destroy.unsafeSubjectID.notificationID,
            object: nil, queue: .current) {
                _ in
                SubjectID.id = Self.unSet
            }
    }
}
