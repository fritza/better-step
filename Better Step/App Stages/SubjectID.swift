//
//  SubjectID.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/28/22.
//

import Foundation

/// An observable wrapper for the subject ID.
///
/// The value is ultimately backed by `UserDefaults` (`AppStorageKeys.subjectID`) upon initialization and update.
///
/// You do not create a `SubjectID`. Instead access it through `SubjectID.shared`.
/// - warning: Do not access the `UserDefault`/`AppStorage` directly.
final class SubjectID: ObservableObject {
    static let shared = SubjectID()

    @Published var subjectID: String? {
        didSet {
            UserDefaults.standard
                .set(subjectID,
                     forKey: AppStorageKeys.subjectID.rawValue)
        }
    }

    private init() {
        subjectID = UserDefaults.standard
            .string(forKey: AppStorageKeys.subjectID.rawValue)
    }
}
