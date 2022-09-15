//
//  SubjectID.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/28/22.
//

import Foundation

struct SubjectID {
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
}
