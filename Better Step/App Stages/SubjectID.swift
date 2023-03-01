//
//  SubjectID.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/28/22.
//

import Foundation
import Combine

/*
 FIXME: Interrupting before all surveys are done
        Treats subsequent runs as beyond-first, and doesn't open the surveys.
 */

/// Subscribers are informed when the subject ID is changed to `.unSet` by way of `SessionID.clearID()`
///
/// _No other pathway emits this notification._ Mere assignment into `.id` or direct manipulation of the user default, won't post. This lets you avoid getting into a loop of set+notify , notify+set+notify...
///
/// `SubjectID` _only_ posts `ResetSubjectIDNotice`, never subscribes.
let ResetSubjectIDNotice = Notification.Name("reset SubjectID")

/// A unique identifier, assigned by the study, for the user and her data. It does _not_ adopt `Identifiable`.
///
/// The identifier itself is just a `String`. but this type validates it and handles `Destroy` `Notification`s to restore the ID to `unset`. A special in-band value for no-known-ID instead of `nil` is to make it easier to initialize `UserDefaults`.
/// - note: All methods are `static` — `SubjectID` wraps a singleton `String`.
/// - warning: Always use `unset` (atw an empty `String`) to indicate the absence of any known `SubjectID`.
struct SubjectID {
    init() {
    }
    /// The `String` value indicating no valid contents.
    static let unSet = ""
    /// The `String` value of the ID.
    static var id: String {
        get {
            if let fromStore = UserDefaults.standard
                .string(forKey: ASKeys.subjectID.rawValue) {
                return fromStore
            }
            else {
                UserDefaults.standard
                    .set(Self.unSet, forKey: ASKeys.subjectID.rawValue)
                return Self.unSet
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ASKeys.subjectID.rawValue)
        }
    }
    
    /// Set the global `SubjectID` to a no-real-value state (`.unSet`).
    ///
    /// Posts `ResetSubjectIDNotice`.
    static func clearID() {
        Self.id = SubjectID.unSet
        NotificationCenter.default
            .post(name: ResetSubjectIDNotice, object: nil)
    }
    
    /// Whether this `SubjectID` carries a subject ID and not `.unSet`.
    static var isSet: Bool {
        SubjectID.id != SubjectID.unSet
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
}
