//
//  BSTAppStageState.swift
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
 - **Reportable**: User-generated data that will be transformed into the contents of files sent to investigators. (`DASIResponseList`), as opposed to configuration metadata (`DASIQuestion`) or specialized marshalling and file-creation objects (`DASIReportFile`).
 - **Marshalling**: Entities (`DASIReportFile`) that take the content of Reportable data sources (`DASIResponseList`), format it, and write it out to files.



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




// MARK: - BSTAppStageState
/// Omnibus aggregate of application-stage operating values
///
/// These include report contents and app-level user defaults (`@AppStorage`).
///
/// You do not instantiate `BSTAppStageState` yourself. Use `.shared` to obtain the single record of application state.
/// - note: It is expected that `BSTAppStageState` should be used as a reference for application-level state, but _not_ as an `@EnvironmentObject`; the thought is that the stages will be more clearly isolated.
///
/// The subject ID goes through `BSTAppStageState` as an `@Observable` property. For cross-launch access, there has to be a write to `@AppStorage`.
final class BSTAppStageState: ObservableObject {
    // FIXME: Find a better place for all-finished
    //        or be reconciled to maintaining a global state.
    //        See if
    @Published var allTasksFinished: Bool = false
    /// Singleton instance of `RootState`
    /// - note: Maybe make this a @StateObject for the App?
//    static var shared = BSTAppStageState()
    /// Initialize a new `RootState`. Use `shared` rather than creating a new one.
    init() {

        // TODO: All per-user resources must be optional.
        // Especially:
        //  - Those that create files.
        //  - Those that capture subject ID upon creation.

        // Probably not:
        //  - Those that get subject ID live, such as DASI/walk records that record sID into each observation.

    }

    var cancellables: Set<AnyCancellable> = []

    // TODO: no-subject and onboarding
    //       the sheet should recognize no-subject and empty the field.

    // MARK: Phase management

    // Structural
    /// Whether the timed walk stage is to be available.
    @AppStorage(AppStorageKeys.includeWalk.rawValue)    var includeWalk = true
    /// Whether the DASI survey is to be available.
    @AppStorage(AppStorageKeys.includeDASISurvey.rawValue)  var includeSurvey = true

    /*
     REMOVE these DASI~ instance and rely on the DASI~ environmentObjects
    // DASI
    var dasiContent: DASIPages = DASIPages()
    var dasiResponses: DASIResponseList = DASIResponseList()
     */
//    var dasiFile: DASIReportFile?

    // Walk

    // MARK: Phase requirement
    private var completed     : Set<BSTAppStages> = []
    private var requiredPhases: Set<BSTAppStages> {
        var retval = Set<BSTAppStages>()
        if includeWalk   { retval.insert(.walk) }
        if includeSurvey { retval.insert(.dasi) }
        assert(!retval.isEmpty,
               "Must set at least one of includeWalk, includeSurvey")
        return retval
    }
}

extension BSTAppStageState {
    // MARK: Phase completion
    /// Mark this phase of the run as complete.
    func didComplete(phase: BSTAppStages) {
        updateReadiness(setting: phase, finished: true)
    }
    /// Mark this phase of the run as incomplete.
    func didNotComplete(phase: BSTAppStages) {
        updateReadiness(setting: phase, finished: false)
    }

    func isCompleted(_ stage: BSTAppStages) -> Bool {
        completed.contains(stage)
    }

    func areCompleted<S: Collection>(settings: S) -> Bool
    where S.Element == BSTAppStages
    {
        let retval = settings.allSatisfy { element in
            isCompleted(element)
        }
        return retval
    }

    private func updateReadiness(setting stage: BSTAppStages, finished: Bool) {
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
        let allCompleted = completed
            .intersection(requiredPhases)
        return allCompleted == requiredPhases
    }
}
