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

 - **Top-level**: Applies to the whole application, such as phase management and subject ID. Top-level data is typically kept in `@AppStorage`.
 - **Phase**: A broad subset of the app's functionality, or information pertaining to it. This often coincides with the selected tab, but the onboarding tab is presented automatically without regard for operational phase.
 - **Phase Workflow**: The information the app tracks to respond to changes in phase..
 - **Configuration**: Immutable descriptions of elements of phases to provide metadata like the question roster.
 - **Reportable**: User-generated data that will be transformed into the contents of files sent to investigators. (`DASIResponses`), as opposed to configuration metadata (`DASIQuestion`) or specialized marshalling and file-creation objects (`DASIReport`).
 - **Marshalling**: Entities (`DASIReport`) that take the content of Reportable data sources (`DASIResponses`), format it, and write it out to files.



 __Top-level:__


 `@AppStorage` that determines the availability of phases (`includeWalk`, `includeSurvey`)
 Current selected phase.
 Not all `@AppStorage` belongs to the top level: For instance, walk duration pertains to that phase only.

 TODO: Add confirmation to the clear buttons.
       Actually, they don't do anything yet.


 __Per-phase__:

 Labels, and identifiers for the workflow of a phase. Non-mutable. Ex: `DASIQuestion`, which provides a roster of DASI questions, their text, and identifiable; `AnswerState` representing the result of a question.

 Now I wonder if simply referencing off the root isn't a safer way to coordinate these.

 ---

 __Auditing `AppStorage` (BIG CHANGE)__:

The subject ID is no longer kept in `AppStorage`. Further problems: How do I persist it?

What goes into `UserDefaults` (`@AppStorage`) should be able to justify itself.

 __Yes__: Everything(?) available to the Configuration page, plus subject ID (Is there any other persistent global?)

 __No__: Anything ephemeral, such as the timed walk-data. We can afford to (should?) drop unfinished data sets that can't be repaired, continued, or what-have-you.

 __Sort of__: DASI responses aren't candidates for `@AppStorage` anyway, but should the app persist and reload responses-in-progress? The app would have to make sure the subject ID was the same.

 */
struct GeneralComments_RootState {}

// MARK: - RootState
/// Omnibus aggregate of application-stage operating values
///
/// These include report contents and app-level user defaults (`@AppStorage`).
///
/// You do not instantiate `RootState` yourself. Use `.shared` to obtain the single record of application state.
/// - note: It is expected that `RootState` should be used as a reference for application-level state, but _not_ as an `@EnvironmentObject`; the thought is that the stages will be more clearly isolated.
///
/// The subject ID goes through `RootState` as an `@Observable` property. For cross-launch access, there has to be a write to `@AppStorage`.
final class RootState: ObservableObject {
    @Published var allTasksFinished: Bool = false
    @Published var sharedSubjectID: String?


    static let subjectIDDefaultsKey = "com.drdr.better-step-test.subject_id"
    let subjectIDSubject = CurrentValueSubject<String?, Never>(
        UserDefaults.standard.string(forKey: subjectIDDefaultsKey)
        )
    // How is subjectIDDefaultsKey, a static constant, usable w/o scope here?



    /// Singleton instance of `RootState`
    /// - note: Maybe make this a @StateObject for the App?
    static var shared = RootState()
    /// Initialize a new `RootState`. Use `shared` rather than creating a new one.
    ///
    /// **About subjectID and UserDefaults**: The subject ID should persist across launches.
    /// The ID is kept in `UserDefaults`,
    private init() {
        let defaults = UserDefaults.standard
        // On launch, reload the subject ID from defaults.
        sharedSubjectID = defaults.string(forKey: Self.subjectIDDefaultsKey)

        // When the subjectID changes, save it to defaults and kick it out through the subject.
        $sharedSubjectID.sink { [self] newID in
            defaults.set(newID, forKey: Self.subjectIDDefaultsKey)
            subjectIDSubject.send(newID)
        }
        .store(in: &cancellables)
    }

    private var cancellables: Set<AnyCancellable> = []

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
        if self.sharedSubjectID == nil { return false }
        let allCompleted = completed
            .intersection(requiredPhases)
        return allCompleted == requiredPhases
    }
}
