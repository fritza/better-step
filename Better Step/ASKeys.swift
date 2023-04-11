//
//  AppStorageKeys.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/28/22.
//

import Foundation


// MARK: - @AppStorage
enum ASKeys: String {
    
    // If false, present the surveys.
    // "Unsafe" because all clients should use ASKeys.isFirstRunComplete instead.
    // isFirstRunComplete is a wrapper on unsafeCompletedFirstRun storage
    case unsafeCompletedFirstRun
    /// The last known subject ID
    case subjectID
    
    /// `String`, a `rawValue` for ``SeriesTag``, for the last-completed phase.
    case phaseProgress
    
    /// **Temporary** storage for the singlie-line DASI report.
    ///
    /// Probably obsoleted by ``ReportingPhase``.
    case temporaryDASIResults
    /// **Temporary** storage for the single-record CSV for Usability
    case tempUsabilityIntsCSV
    
//    case _7DayKey
    
    /// Represent the arrival at the final scene (ConclusionView)
    /// as a Date timeIntervalSinceEpoch TimeInterval.
    /// - warning: This is to be used _only_ for the backing store in `UserDefaults`. Live code shouldl rely on ``lastCompletionValue``  instead.
    case lastCompletedDate
    
    /// Whether the user has completed all phases of the workflow.
    ///
    /// Usually, client code should rely on `@AppStorage` instead, but that's not available from static functions such as ``TopPhases.resetToFirst()``.
    static var isFirstRunComplete: Bool {
        get {
            UserDefaults.standard
                .bool(forKey: ASKeys.unsafeCompletedFirstRun.rawValue)
        }
        set {
            UserDefaults.standard
                .setValue(newValue, forKey: ASKeys.unsafeCompletedFirstRun.rawValue)
        }
    }
    
    // MARK: - Completion date

/*
    ///  The last date at which the user made it all the way through a session.
    ///
    ///  If none has been set this will be `.distantPast`. Client code will use this to determine whether the user should be warned-off from retries within a certain interval (like 1 calendar day?).
    ///
    ///  Clients that want to put at timestamp on a fresh completion should use `ASKeys.lastCompletionDate = Date()`
    static var lastCompletionValue: Date {
        get {
            guard let interval = UserDefaults.standard
                .value(forKey: ASKeys.lastCompletedDate.rawValue) as? TimeInterval
            else { return .distantPast }
                let asDate = Date(timeIntervalSince1970: interval)
            return asDate
        }
        set {
            let since1970 = newValue.timeIntervalSince1970
            UserDefaults.standard
                .set(since1970, forKey: ASKeys.lastCompletedDate.rawValue)
        }
    }
*/

    // FIXME: Is this supposed to invalidate the whole history?
    //            Appears so; it sets the first run to false(?!)
//    static func spoilLast7DReport() {
//        UserDefaults.standard
//            .setValue(0, forKey: ASKeys.unsafeCompletedFirstRun.rawValue)
//    }
}

extension ASKeys {
    static func idAndFirstRunAreConsistent(
        _ file: String = #fileID,
        _ line: Int = #line) -> Bool
    {
        let ud = UserDefaults.standard
        
        guard let storedSubjectID = ud
            .string(forKey: ASKeys.subjectID.rawValue) else {
            print("Uninitialized Subject ID: \(file):\(line)")
            return false
        }
        
        let didCompleteFirst = ud
            .bool(forKey: ASKeys.unsafeCompletedFirstRun.rawValue)
        
        // If there's no subject, can't have finished.
        // Primitive access to `.unSet` is intended.
        if storedSubjectID == SubjectID.unSet
            && didCompleteFirst {
            print("Unset Subject ID, but “completed” first: \(file):\(line)")
            return false
        }
        return true
    }
}
