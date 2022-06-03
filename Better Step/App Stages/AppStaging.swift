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
    var stage: Stage { get }

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

    let name: String
    let id: Int
    let stage: AnyAppStaging
    let _perform: () -> Void
}

class AnyAppStaging: AppStaging {
    typealias Task = AnyStageTasking

    let name: String
    let id: Int
/*
    let statusClosure: () -> String
    init<Base:TaskLike>(_ base: Base) {
        id = base.id
        name = base.name
        statusClosure = {
            return base.status
        }
    }
*/

    typealias TaskClosure = () -> AnyStageTasking?
    let currentClosure  : TaskClosure
    let setClosure      : (AnyStageTasking) -> Void
    let prevClosure     : TaskClosure
    let nextClosure     : TaskClosure

    let goNextClosure   : TaskClosure
    let goBackClosure   : TaskClosure

    init<AS: AppStaging>(boundValue: AS) {
        (name, id) = (boundValue.name, boundValue.id)
        currentClosure = {
            guard let curr = boundValue.currentTask else { return nil }
            return AnyStageTasking(curr)
        }

        prevClosure = {
            guard let val = boundValue.prevTask else {
                return nil
            }
            return AnyStageTasking(val)
        }
        nextClosure = {
            guard let val = boundValue.nextTask else {
                return nil
            }
            return AnyStageTasking(val)
        }
        goNextClosure = {
            guard let val = boundValue.incrementTask() else {
                return nil
            }
            return AnyStageTasking(val)
        }
        goBackClosure = {
            guard let val = boundValue.decrementTask() else {
                return nil
            }
            return AnyStageTasking(val)
        }
        setClosure = {
            anyTask in
            #warning("Watch the following cast:")
            boundValue.setCurrentTask(to: anyTask as! AS.Task)
        }
    }

    func setCurrentTask(to new: AnyStageTasking) {
        setClosure(new)
    }
    var currentTask : AnyStageTasking? { currentClosure() }
    var nextTask    : AnyStageTasking? { nextClosure()    }
    var prevTask    : AnyStageTasking? { prevClosure()    }
    // FIXME: Seems no way to set the current task.

//    let _setCurrentTask: (AnyStageTasking) -> Void
//    func setCurrentTask(to next: AnyStageTasking) {
//        _setCurrentTask(next)
//    }

    func incrementTask() -> AnyStageTasking? { goNextClosure() }
    func decrementTask() -> AnyStageTasking? { goBackClosure() }
}

// Example: all tasks of the DASI stage
protocol AppStaging: AnyObject & Hashable {
    associatedtype Task: StageTasking
    var name: String { get }
    var id: Int { get }

    var currentTask: Task? { get }
    func setCurrentTask(to: Task)

    var nextTask: Task? { get }
    func incrementTask()    -> Task?
    var prevTask: Task? { get }
    func decrementTask()    -> Task?
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

    func setCurrentTask(to: DASIQuestionTask) {
        // COMPLETE ME!
    }
    var currentTask: DASIQuestionTask? = nil
    var nextTask: DASIQuestionTask? { return nil }
    var prevTask: DASIQuestionTask? { return nil }
    func incrementTask() -> DASIQuestionTask? { return nil }
    func decrementTask() -> DASIQuestionTask? { return nil }

    // TODO: Can we have the task-sequence DSL? It's just a sequence here.
    //       But the DSL can probably add decorations like restoration points
    //       Gosh, maybe even save/destroy actions.


}

