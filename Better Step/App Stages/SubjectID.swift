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

    /// Remove the backing `UserDefaults` value for the subject ID.
    ///
    /// **Use with caution:** The remove-all-data button depends on a lagging Subject ID; clearing it would make it difficult (or worse) to identify what files to delete.
    static func clear() {
        UserDefaults.standard
            .removeObject(forKey: AppStorageKeys.subjectID.rawValue)
    }

    /// The ID of the active subject/user. If none, `nil`. Initially from `UserDefaults` (`subjectID`)
    ///
    /// Setting `subjectID` also sets
    /// - `UserDefaults` (`subjectID`)
    /// - `noSubjectID` if `subjectID` is `nil`
    /// - `unwrappedSubjectID`, to value, or "" if `nil.
    ///
    /// - note: `nil` value at startup to trigger presentation of `SubjectIDSheetView`.
    ///
    @Published var subjectID: String? {
        didSet {
            UserDefaults.standard
                .set(subjectID,
                     forKey: AppStorageKeys.subjectID.rawValue)
        }
    }

    private init() {
        subjectID = UserDefaults.standard
            .string(forKey: AppStorageKeys.subjectID.rawValue) ?? ""
    }
}
