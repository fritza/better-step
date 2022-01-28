//
//  STGlobalState.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/28/22.
//

import Foundation

enum AppStages: Hashable {
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

final class GlobalState: ObservableObject {
    static var current: GlobalState!

    private var completed     : Set<AppStages> = []
    private let requiredPhases: Set<AppStages> = [.walk, .dasi]

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
    func complete(_ stage: AppStages) {
        updateReadiness(setting: stage, finished: true)
    }
    /// Mark this phase of the run as incomplete.
    func unComplete(_ stage: AppStages) {
        updateReadiness(setting: stage, finished: false)
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

