//
//  PhaseManager.swift
//  Async Accel
//
//  Created by Fritz Anderson on 4/5/22.
//

import Foundation
import Combine
import SwiftUI

final class PhaseManager: ObservableObject {
    @Published var selectedStage: AppStages = .dasi
    @Published var allTasksFinished: Bool = false
    // FIXME: apparently doesn't see EnvironmentObjects
    //        Future commit, remove this line.
    @EnvironmentObject var subjectID: SubjectID

    @AppStorage(AppStorageKeys.includeWalk.rawValue)    var includeWalk = true
    @AppStorage(AppStorageKeys.includeSurvey.rawValue)  var includeSurvey = true

    // Skip (no longer a factotum object)
    // dasiContent, dasiResponses, dasiFile

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

extension PhaseManager {
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
        guard SubjectID.initialized else {
            return false
        }
        let allCompleted = completed
            .intersection(requiredPhases)
        return allCompleted == requiredPhases
    }
}
