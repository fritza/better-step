//
//  AppStaging.swift
//  Better Step
//
//  Created by Fritz Anderson on 6/3/22.
//

import Foundation

/// The tasks to be performed in an `AppStaging` workflow: A **stage's tasks**. An example would be the questions and interstitials in a DASI survey.
///
/// Hashed and equated solely on the basis of `id`. The task knows how to perform itself through the `perform()` instance method.
/// - warning: Take care that the task `id`s be unique within a stage.
protocol StageTasking: AnyObject & Hashable & Identifiable {
    associatedtype Stage: AppStaging

    var name    : String { get }
    var id      : Int    { get }
    var stage   : Stage  { get }

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

class AnyStageTasking: StageTasking {
    // FIXME: This doesn't trampoline into the bound stage-tasking. 
    func perform() {
        _perform()
    }

    init<ST:StageTasking>(_ boundValue: ST)
    {
        (name, id) = (boundValue.name, boundValue.id)
        stage = AnyAppStaging(boundValue: boundValue.stage)
        _perform = boundValue.perform
    }

    // Passthroughs:
    let name    : String
    let id      : Int
    let stage   : AnyAppStaging
    let _perform: () -> Void
}


/// One of the workflows among an app's repertoire: An **app's staging**.
///
/// Stages are comprised of `StageTasking` elements. Stages do not share tasks; tasks must appear only once in the workflow. Each task identifies the ones before and after (if any), making it possible to iterate the steps without the stage having to know anything about them.
protocol AppStaging: AnyObject & Hashable {
    associatedtype Task: StageTasking
    var name: String                    { get }
    var id: Int                         { get }

    var currentTask: Task?              { get }
    func setCurrentTask(to: Task)

    /// The `StageTasking`, if any, after this one
    var nextTask            :   Task?   { get }
    func incrementTask()    ->  Task?

    /// The `StageTasking`, if any, before this one
    var prevTask            :   Task?   { get }
    func decrementTask()    ->  Task?
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
    var stage: DASIStage
    let name: String = "DASIQuestionTask"
    let id: Int
    func perform() {

    }

    init(index: Int, stage: DASIStage) {
        id         = index
        self.stage = stage
    }
}

class DASIStage: AppStaging {
    var tasks: Array<AnyStageTasking>

    var name: String
    var id: Int

    public init(name: String, id: Int) {
        self.name = name
        self.id = id

        self.tasks = []
    }

    #warning("Task sequencing not implemented.")

    func setCurrentTask(to: DASIQuestionTask) {
        // COMPLETE ME!
    }
    var currentTask: DASIQuestionTask? = nil
    var nextTask: DASIQuestionTask? { return nil }
    var prevTask: DASIQuestionTask? { return nil }
    func incrementTask() -> DASIQuestionTask? { return nil }
    func decrementTask() -> DASIQuestionTask? { return nil }
}

