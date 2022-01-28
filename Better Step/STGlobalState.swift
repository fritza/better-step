//
//  STGlobalState.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/28/22.
//

import Foundation

enum GlobalState: Hashable {
    case onboard
    case dasi, walk
    case report
    case configuration

    static var subjectID: String? = nil {
        didSet {
            guard subjectID != oldValue else { return }
            clear()
        }
    }

    static func clear() { completed  = []             }
    func complete()     { Self.completed.insert(self) }
    func unComplete()   { Self.completed.remove(self) }
    static var readyToReport: Bool {
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
