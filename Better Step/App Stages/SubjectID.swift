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
}
