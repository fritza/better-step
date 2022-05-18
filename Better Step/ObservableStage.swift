//
//  ObservableStage.swift
//  Better Step
//
//  Created by Fritz Anderson on 5/11/22.
//

import Foundation
import Combine
import SwiftUI

final class ObservableStage: ObservableObject {
    @AppStorage(AppStorageKeys.includeUsabilitySurvey.rawValue) var includeUsability: Bool = false

    @Published var stage = Stage()
    @Published var isReadyToReport: Bool = false
    @Published var isReadyForWalk : Bool = false

    @AppStorage(AppStorageKeys.includeDASISurvey.rawValue)
    var includeDASIPersistent       = true

    var walkPrerequisites: Stage {
        var walkPrerequisites: Stage = [.subjectID]
        if includeDASIPersistent {
            walkPrerequisites.insert(.dasi)
        }
        return walkPrerequisites
    }

    init() {
        updateDependentStages()
    }

    private func updateDependentStages() {
        isReadyToReport = stage.isReadyToReport
        isReadyForWalk = stage.meetsCompletion(of: walkPrerequisites)
    }

    func complete(_ incoming: Stage) {
        stage = stage.withCompletion(of: incoming)
        updateDependentStages()
    }

    func uncomplete(_ offGoing: Stage) {
        stage = stage.withoutCompletion(of: offGoing)
        updateDependentStages()
    }

    func resetForSubject() {
        stage = .notClearable
        updateDependentStages()
    }
}
