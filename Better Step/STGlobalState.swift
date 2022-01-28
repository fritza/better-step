//
//  STGlobalState.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/28/22.
//

import Foundation

enum GlobalState: Hashable {
    /// A new user ID has been entered.
    case onboard
    /// The user has completed these activities
    case dasi, walk
    /// The user has entered the Report tab
    ///
    /// You can't report without a `subjectID`
    case report
    case configuration

    static var subjectID: String? = nil {
        didSet {
            guard subjectID != oldValue else { return }
            clear()
            Self.completed = [.onboard]
        }
    }

    /// Clear out the completion records, optionally setting a new `subjectID`
    ///
    /// If no (`nil`) subject ID is provided, the existing subject ID will be preserved.
    /// - parameter newUserID: The subject ID for the exercise. If `nil`, ( the default), the global subject ID will not be changed.
    static func clear(newUserID: String? = nil) {
        completed  = []
        if let newUserID = newUserID {
            subjectID = newUserID
        }
    }
    /// Mark this phase of the run as complete.
    func complete()     { Self.completed.insert(self) }
    /// Mark this phase of the run as incomplete.
    func unComplete()   { Self.completed.remove(self) }
    /// Whether the active tasks (survey and tasks) have all been completed _and_ there is a known subject ID;
    static var readyToReport: Bool {
        if subjectID == nil { return false }
        let allCompleted = completed
            .intersection(requiredPhases)
        return allCompleted == requiredPhases
    }

    private static var completed     : Set<GlobalState> = []
    private static let requiredPhases: Set<GlobalState> = [.walk, .dasi]

    private func markCompleted() {
        Self.completed   .insert(self)
    }
}


