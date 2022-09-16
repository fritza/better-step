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
                .string(forKey: AppStorageKeys.subjectID.rawValue) {
                return fromStore
            }
            else {
                UserDefaults.standard.set("", forKey: AppStorageKeys.subjectID.rawValue)
                return ""
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AppStorageKeys.subjectID.rawValue)
        }
    }

    static var validated: String? {
//        guard !id.isEmpty else { return nil }
        let desiredCharacters = CharacterSet.whitespacesAndNewlines.inverted
        let scanner = Scanner(string: id)
        var trimmed = scanner.scanCharacters(from: desiredCharacters)

        if let trimmed, !trimmed.isEmpty {
            return trimmed
        }

        return nil
    }
}
