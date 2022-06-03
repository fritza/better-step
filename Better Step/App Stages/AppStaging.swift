//
//  AppStaging.swift
//  Better Step
//
//  Created by Fritz Anderson on 6/3/22.
//

import Foundation

// Example the questions or interstitials of a DASI stage
protocol StageTasking: AnyObject & Hashable {
    associatedtype Stage: AppStaging
    var name: String { get }
    var id: Int { get }
    var stage: Stage? { get }

    func perform()
}

extension StageTasking {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return (lhs.id == rhs.id)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class AnyStageTasking<ST: StageTasking>: StageTasking {
    var captured: ST
    init(_ boundValue: ST) {
        captured = boundValue
    }

    // Passthroughs:

    var name: String { captured.name }
    var id: Int { captured.id }
    var stage: ST.Stage? { captured.stage }
    func perform() { captured.perform() }
}

// Example: all tasks of the DASI stage
protocol AppStaging: AnyObject & Hashable {
    associatedtype Task: StageTasking
    var name: String { get }
    var id: Int { get }

    var currentTask: Task? { get set }

    var nextTask: Task? { get }
    func incrementTask() -> Task?
    var prevTask: Task? { get }
    func decrementTask() -> Task?
}

extension AppStaging {
    // FIXME: This prevents comparing stages of different types
    //        However, an AnyAppStaging should take care of that.
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class DASIQuestionTask: StageTasking {
    let name: String = "DASIQuestionTask"
    let id: Int
    var stage: DASIStage?
    func perform() {

    }

    init(index: Int, stage: DASIStage) {
        id         = index
        self.stage = stage
    }
}

class DASIStage: AppStaging {
    var name: String
    var id: Int

    public init(name: String, id: Int) {
        self.name = name
        self.id = id
    }

    var currentTask: DASIQuestionTask? = nil
    var nextTask: DASIQuestionTask? { return nil }
    func incrementTask() -> DASIQuestionTask? { return nil }
    var prevTask: DASIQuestionTask? { return nil }
    func decrementTask() -> DASIQuestionTask? { return nil }

    // TODO: Can we have the task-sequence DSL? It's just a sequence here.
    //       But the DSL can probably add decorations like restoration points
    //       Gosh, maybe even save/destroy actions.


}

