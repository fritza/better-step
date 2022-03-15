//
//  STGlobalState.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/28/22.
//

import Foundation
import SwiftUI

enum AppStages: Hashable, CaseIterable {
    /// A new user ID has been entered.
    case onboard
    /// The user has completed these activities
    case dasi, walk
    /// The user has entered the Report tab
    ///
    /// You can't report without a `subjectID`
    case report
    case configuration

}

final class ApplicationState: ObservableObject {
    @AppStorage(AppStorageKeys.includeWalk.rawValue)    var includeWalk = true
    @AppStorage(AppStorageKeys.includeSurvey.rawValue)  var includeSurvey = true

    static var current: ApplicationState!

    private var completed     : Set<AppStages> = []
    private var requiredPhases: Set<AppStages> {
        var retval = Set<AppStages>()
        if includeWalk   { retval.insert(.walk) }
        if includeSurvey { retval.insert(.dasi) }
        assert(!retval.isEmpty,
               "Must set at least one of includeWalk, includeSurvey")
        return retval
    }

    init() {
        let ud = UserDefaults.standard
        subjectID = ud.string(forKey: AppStorageKeys.subjectID.rawValue)
        ?? ""
        Self.current = self
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

