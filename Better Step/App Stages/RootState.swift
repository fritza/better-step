//
//  RootState.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/28/22.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Design principles

/**
 Design principles for state and configuration objects

__Terms:__

 - **Top-level**: Applies to the whole application, such as phase management and subject ID. Top-level data is typically kept in @AppStorage.

 - **Phase**: A broad subset of the app's functionality, or information pertaining to it. This often coincides with the selected tab, but the onboarding tab is presented automatically without regard for operational phase.

 -  **Configuration**: Immutable descriptions of elements of phases to provide metadata like the question roster.

- **Reportable**: Data to transcribe into files for reporting to investigators (`DASIResponses`), as opposed to configuration metadata (`DASIQuestion`)

 __Top-level:__


 `@AppStorage` that determines the availability of phases (`includeWalk`, `includeSurvey`)
 Current selected phase.
 Not all `@AppStorage` belongs to the top level: For instance, walk duration pertains to that phase only.

 TODO: Add conformation to the clear buttons.
       Actually, they don't do anything yet.

 There should be a top-level, omnibus class to hold both the global state and to refer to the per-phase configuration and reportable data.

 Per-phase:
 =

 Labels, and identifiers for the workflow of a phase. Non-mutable. Ex: `DASIQuestion`, which provides a roster of DASI questions, their text, and identifiable; `AnswerState` representing the result of a question.


 **I had considered** using the subsidiary data (`DASIPages`) as `EnvironmentObject`s, even though they could be referenced through `RootState`, because I thought the "deep link" would separate concerns.

 Now I wonder if simply referencing off the root isn't a safer way to coordinate these.
 */
struct GeneralComments_RootState {}

// MARK: - RootState
/// Omnibus aggregate of application-stage operating values
///
/// These include report contents and app-level user defaults (`@AppStorage`).
///
/// You do not instantiate `RootState` yourself. Use `.shared` to obtain the single record of application state.
/// - note: It is expected that `RootState` should be used as a reference for application-level state, but _not_ as an `@EnvironmentObject`; the thought is that the stages will be more clearly isolated.
final class RootState: ObservableObject {
    @Published var allTasksFinished: Bool = false

    /// Singleton instance of `RootState`
    static var shared = RootState()
    /// Initialize a new `RootState`. Use `shared` rather than creating a new one.
    private init() { }

    /// The content of subject-id strings if no actual value is present.
    ///
    /// **See also** the `subjectID` key into `AppStorage`, which must be coordinated with this value
    /// - bug: Not sure why this can't be done with `nil`.
    @available(*, deprecated,
                message: "Experimental, may be replaced with literal nil")
   static let noSubjectString = "NO SUBJECT"

    /// The subject ID, as saved in `UserDefaults`. "NO SUBJECT" is a flag for an unassigned ID.
    ///
    /// **See also** the  static `subjectID` constant, which must be coordinated with this value
    /// - bug: Not sure why this can't be done with `nil`.
    @available(*, deprecated,
                message: "Default value may be replaced with literal nil")
    @AppStorage(AppStorageKeys.subjectID.rawValue) var subjectID: String = "NO SUBJECT"

    // TODO: no-subject and onboarding
    //       the sheet should recognize no-subject and empty the field.

    // MARK: Phase management

    // Structural
    /// Whether the timed walk stage is to be available.
    @AppStorage(AppStorageKeys.includeWalk.rawValue)    var includeWalk = true
    /// Whether the DASI survey is to be available.
    @AppStorage(AppStorageKeys.includeSurvey.rawValue)  var includeSurvey = true

    // DASI
    var dasiContent: DASIPages = DASIPages()
    var dasiResponses: DASIResponses = DASIResponses()

    // Walk

    // MARK: Phase completion
    private var completed     : Set<AppStages> = []
    private var requiredPhases: Set<AppStages> {
        var retval = Set<AppStages>()
        if includeWalk   { retval.insert(.walk) }
        if includeSurvey { retval.insert(.dasi) }
        assert(!retval.isEmpty,
               "Must set at least one of includeWalk, includeSurvey")
        return retval
    }
}

extension RootState {
    // MARK: Phase completion
    /// Mark this phase of the run as complete.
    func didComplete(phase: AppStages) {
        updateReadiness(setting: phase, finished: true)
    }
    /// Mark this phase of the run as incomplete.
    func didNotComplete(phase: AppStages) {
        updateReadiness(setting: phase, finished: false)
    }

    func isCompleted(_ stage: AppStages) -> Bool {
        completed.contains(stage)
    }

    func areCompleted<S: Collection>(settings: S) -> Bool
    where S.Element == AppStages
    {
        let retval = settings.allSatisfy { element in
            isCompleted(element)
        }
        return retval
    }

    private func updateReadiness(setting stage: AppStages, finished: Bool) {
        let wasReady = checkReadyToReport

        if finished { completed.insert(stage) }
        else { completed.remove(stage)  }

        let amReady = checkReadyToReport
        if wasReady != amReady {
            allTasksFinished = amReady
        }
    }

    /// Whether the active tasks (survey and tasks) have all been completed _and_ there is a known subject ID;
    var checkReadyToReport: Bool {
        if subjectID == RootState.noSubjectString { return false }
        let allCompleted = completed
            .intersection(requiredPhases)
        return allCompleted == requiredPhases
    }
}

// MARK: - ApplicationState

@available(*, unavailable, message: "Use RootState instead")
final class ApplicationState: ObservableObject {
    }
    /*
    // MARK: Properties
    @AppStorage(AppStorageKeys.includeWalk.rawValue)    var includeWalk = true
    @AppStorage(AppStorageKeys.includeSurvey.rawValue)  var includeSurvey = true

    static var shared = ApplicationState()

    private var completed     : Set<AppStages> = []
    private var requiredPhases: Set<AppStages> {
        var retval = Set<AppStages>()
        if includeWalk   { retval.insert(.walk) }
        if includeSurvey { retval.insert(.dasi) }
        assert(!retval.isEmpty,
               "Must set at least one of includeWalk, includeSurvey")
        return retval
    }

    private init() {
        let ud = UserDefaults.standard
        subjectID = ud.string(forKey: AppStorageKeys.subjectID.rawValue)
        ?? ""
    }

    @Published var subjectID: String = "νεμο" {
        didSet {
            #warning("This resets progress while typing, even if it would eventually match")
            if subjectID != oldValue {
//                clear(newUserID: subjectID)
                completed = []
                }
            completed = [.onboard]


            #warning("Make sure this is the right place to update the subjectID")
            let ud = UserDefaults.standard
            ud.set(subjectID, forKey: AppStorageKeys.subjectID.rawValue)
        }
    }

    /// Clear out the completion records, optionally setting a new `subjectID`
    ///
    /// If no (`nil`) subject ID is provided, the existing subject ID will be preserved.
    /// - parameter newUserID: The subject ID for the exercise. If `nil`, ( the default), the global subject ID will not be changed.
    func clear(newUserID: String? = nil) {
        completed  = []
        if let newUserID = newUserID {
            subjectID = newUserID
        }
        else {
            subjectID = ""
        }
    }

    // MARK: Phase completion
    @Published var allTasksFinished: Bool = false

    /// Mark this phase of the run as complete.
    func didComplete(phase: AppStages) {
        updateReadiness(setting: phase, finished: true)
    }
    /// Mark this phase of the run as incomplete.
    func didNotComplete(phase: AppStages) {
        updateReadiness(setting: phase, finished: false)
    }

    func isCompleted(_ stage: AppStages) -> Bool {
        completed.contains(stage)
    }

    func areCompleted<S: Collection>(settings: S) -> Bool
    where S.Element == AppStages
    {
        let retval = settings.allSatisfy { element in
            isCompleted(element)
        }
        return retval
    }

    private func updateReadiness(setting stage: AppStages, finished: Bool) {
        let wasReady = checkReadyToReport

        if finished { completed.insert(stage) }
        else { completed.remove(stage)  }

        let amReady = checkReadyToReport
        if wasReady != amReady {
            allTasksFinished = amReady
        }
    }

    /// Whether the active tasks (survey and tasks) have all been completed _and_ there is a known subject ID;
    var checkReadyToReport: Bool {
        if subjectID == "" { return false }
        let allCompleted = completed
            .intersection(requiredPhases)
        return allCompleted == requiredPhases
    }
}
*/
