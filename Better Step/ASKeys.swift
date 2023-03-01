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
    
    case _7DayKey
    
    /// Represent the arrival at the final scene (ConclusionView)
    /// as a Date timeIntervalSinceEpoch TimeInterval.
    /// - warning: This is to be used _only_ for the backing store in `UserDefaults`. Live code shouldl rely on ``lastCompletionValue``  instead.
    case lastCompletedDate
    
    func negate() {
        let ud = UserDefaults.standard
        ud.set(false, forKey: self.rawValue)
    }
    
    
    /// Remove a value from `UserDefaults`.
    func removeDefault() {
        let ud = UserDefaults.standard
        ud.removeObject(forKey: self.rawValue)
    }
    
    /// Remove, `false`, or reset all the `ASKeys`
    static func revertPhaseDefaults() {
        let ud = UserDefaults.standard

        let boolKeys: [ASKeys] = [
            .unsafeCompletedFirstRun,
        ]
        boolKeys.forEach { ud.set(false, forKey: $0.rawValue) }
        let nillableKeys: [ASKeys] = [
            .tempUsabilityIntsCSV, .temporaryDASIResults,
        ]
        nillableKeys.forEach { $0.removeDefault() }
        
        Self.spoilLast7DReport()
        
//        ud.set("", forKey: ASKeys.phaseProgress.rawValue)
        
        // This won't be the only place that SubjectID
        // will be un-set, but it can't hurt.
        ud.setValue(SubjectID.unSet,
                    forKey: Self.subjectID.rawValue)
        isFirstRunComplete = false
    }
    
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
    
    static var tooEarlyToRepeat: Bool {
        let lastCompletion: String = lastCompletionValue.ymd
        let todayYMD      : String = Date().ymd
        return lastCompletion == todayYMD
    }
    
    // FIXME: Is this supposed to invalidate the whole history?
    //            Appears so; it sets the first run to false(?!)
    static func spoilLast7DReport() {
        UserDefaults.standard
            .setValue(0, forKey: ASKeys.unsafeCompletedFirstRun.rawValue)
    }
    
    static var dateOfLast7DReport: Date {
        get {
            let stored = UserDefaults.standard
                .double(forKey: ASKeys._7DayKey.rawValue)
            return (stored == 0.0) ? Date.distantPast
            : Date(timeIntervalSinceReferenceDate: stored)
        }
        set {
            let interval = newValue.timeIntervalSinceReferenceDate
            UserDefaults.standard
                .setValue(interval, forKey: ASKeys._7DayKey.rawValue)
        }
    }
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
        if storedSubjectID == SubjectID.unSet
            && didCompleteFirst {
            print("Unset Subject ID, but “completed” first: \(file):\(line)")
            return false
        }
        return true
    }

}

/**
 # About inspection mode
 
 ## Presentation in Deployment
 
 The deployed app isn't really amenable to free navigation — duck out of the DASI survey, take the first walk, finish the survey, take the second walk (though that may be a decent idea). It may vary because there are one-shot stages (DASI, _e.g._), but compliance isn't at all difficult: If `@AppStorage` says a one-shot has been done already, don't include it in subsequent runs.
 
 ## Presentation for Evaluation
 
 Inspection mode shows the stages in a flat presentation like a tab view. No preconditions are checked (this may turn out to be impractical, but that's the idea). An evaluator wants to see the stages one-at-a-time. There may be adjustments: The walk interstitial  might be presented _e.g._ once upon completion of the first walk, then again at the start of the second.
 
 
 ## Evaluation Mode
 
 Assuming you want the same app to present both deployment and evaluation at all, how do you switch it on and off? In evaluation mode, this is easy: Add it to the Settings tab. In deployment, the user by definition is not to be admitted to the settings and therefore to whatever would expose evaluation mode. There has to be a secret handshake that's not obvious to the lay user.
 
 It's tempting to introduce a "cheat code" consisting of a strange sequence of taps, tilts, and shakes, but that's not 100% safe, and is accident-prone for the researchers.
 
 Instead, is there room for a "gear" button in all the navigation bars? It's obvious, unsurprising, and can be guarded by a passcode.
 
 The logical place is in the leading end of the nav bar, trailing if necessary after any "← Back" button. I hope it'll fit. No matter what the mode, this can be the one-and-only access to the **Settings** screen. Suppose the passcode sheet is attached to the Settings screen to block access.
 
 * Present the passcode sheet before every entry, regardless of whether the current mode is evaluation?
 * Present it only if the current mode is deployment? You'd revert to deployment mode with a button in the Settings sheet.
 
 I like the second of these better.
 
 ## Tracking the Mode
 
 Does the mode persist across launches? Across being put in the background?
 
 If this were a matter of security — don't  leave ev mode on while the phone is lying around — I don't think it's a serious concern. Keep the selection in the prefs, under the key `inspectionMode`.
 
 ### Root Presentation
 
 In Deployment mode, present the next step in the process. Rely on `.completedStages` to select. Ideally, if you're in the middle, you'll be state-restored to that.
 
 In Evaluation, the root presentation is a `TabView`, which is present on-screen at all times. This makes it possible that the user will step laterally or temporally between stage trees. Ideally, the views preserve progress (DASI 5 unanswered, DASI 5 presented). **Query:** What happens if the selected stage depends on results of stages not yet completeed? Possibly you do it like a Preview, in which you make something up.
 */
