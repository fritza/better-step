//
//  AppStorageKeys.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/28/22.
//

import Foundation

// MARK: - @AppStorage
enum ASKeys: String {
    /// How long the timed walk is to last, in _minutes,_ e.g. 6.
    case walkInMinutes
    /// The frequency in Hertz (e.g. 120) for sampling the accelerometer.
    case walkSamplingRate
    /// If `false`, report acceleration in three axes; otherwise as the vector magnitude.
    case reportAsMagnitude
    /// `String` the email address to receive report archive files.
    case reportingEmail

    /// If `false`, this is the first run of the app and needs to collect SubjectID, DASI, and Usability
    case hasCompletedSurveys
    /// The last known subject ID
    case subjectID
    /// Whether the DASI stage is complete
    case collectedDASI

    /// Whether the satisfaction scale substage of the usability phase is complete
    case collectedUsability

    case tempUsabilityIntsCSV

    /// A single shared interpretation of what constitutes completion of the walk.
    case perfomedWalk

    /// `String`, an identifier for the last-completed phase.
    /// 
    ///     The phases are strictly ordered, so this obsoletes many of the "collected/completed" keys.
    case phaseProgress
    
    /// Whether the context form substage of the usability phase is complete.
    case collectedFreehandU

    case temporaryDASIResults

    case daysSince7DayReport

    /// `Int` allowable length of timed walk _in minutes._ Do not confuse with the `walkInMinutes` preference key,  which is the specific duration to use.
    static let dasiWalkRange = (1...10)

    static func resetSubjectData() {
        let defaults = UserDefaults.standard
        defaults.set("", forKey: ASKeys.subjectID.rawValue)

        let stringPrefs: [ASKeys] = [.collectedDASI, .collectedFreehandU, .collectedUsability]
        let keys = stringPrefs.map(\.rawValue)
        for key in keys {
            defaults.set(false, forKey: key)
        }
    }

    func negate() {
        let ud = UserDefaults.standard
        ud.set(false, forKey: self.rawValue)
    }


    /// Remove or replace a value from `UserDefaults`.
    ///
    /// Replacement counts as “erasure” even though it's simply assignment, because
    /// * some initial values are in-band, such as `SubjectID`, which is initially `unSet` ( `""`)
    /// * using the function clarifies the intention.
    /// - Parameters:
    ///   - newValue: If not `nil` (the default) save this value under the key.
    func eraseDefault() {
        let ud = UserDefaults.standard
        ud.removeObject(forKey: self.rawValue)
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
