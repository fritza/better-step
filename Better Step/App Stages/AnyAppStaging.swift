//
//  AnyAppStaging.swift
//  Better Step
//
//  Created by Fritz Anderson on 6/15/22.
//

import Foundation

/// A type-erased container for any instance of `AppStaging`.
class AnyAppStaging: AppStaging {
    typealias Task = AnyStageTasking

    let name: String
    let id: Int

    typealias TaskClosure = () -> AnyStageTasking?
    /// **Trampoline:** returning the wrapped `currentTask` as `AnyStageTasking`.
    private let currentClosure  : TaskClosure
    /// **Trampoline:** pass a new value to the wrapped `setCurrentTask(to:as:)`
    private let setClosure      : (AnyStageTasking) -> Void

    /// **Trampoline:** returning the wrapped `prevTask` as `AnyStageTasking`.
    private let prevClosure     : TaskClosure
    /// **Trampoline:** returning the wrapped `.nextTask` (task _after_ the current task) as `AnyStageTasking`.
    private let nextClosure     : TaskClosure


    /// **Trampoline:** increment the current task _within_ the wrapped stage.
    private let goNextClosure   : TaskClosure
    /// **Trampoline:** decrement the current task _within_ the wrapped stage.
    private let goBackClosure   : TaskClosure

    /// Wap an `AppStaging` instance into an `AnyAppStaging`, erasing its type.
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

    /// Make `new` the active task in the erased stage.
    func setCurrentTask(to new: AnyStageTasking) {
        setClosure(new)
    }
    /// The erased active task in the erased stage.
    var currentTask : AnyStageTasking? { currentClosure() }
    /// The erased task _after_ the currently-active one.
    var nextTask    : AnyStageTasking? { nextClosure()    }
    /// The erased task _before_ the currently-active one.
    var prevTask    : AnyStageTasking? { prevClosure()    }

    /// Advance the active task to the one after the current one.
    func incrementTask() -> AnyStageTasking? { goNextClosure() }
    /// Retard the active task to the one before the current one.
    func decrementTask() -> AnyStageTasking? { goBackClosure() }

    // MARK: - Equatable
    static func == <R>  (lhs: AnyAppStaging, rhs: R) -> Bool
    where R: AnyAppStaging {
        lhs.id == rhs.id
    }

    static func == <L>  (lhs: L, rhs: AnyAppStaging) -> Bool
    where L: AnyAppStaging {
        lhs.id == rhs.id
    }
}
