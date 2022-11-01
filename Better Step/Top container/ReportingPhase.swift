//
//  ReportingPhase.swift
//  Better Step
//
//  Created by Fritz Anderson on 11/1/22.
//

import Foundation

/**
 Adopters are expected to be nodes in a hierarchy of tasks matching 1:1 with result types.

 In SwiftUI, an adopter may be a node in a tree of `View`s. A roster of tasks may be
 kept in phases (higher-order tasks) that direct which task will be presented next.

 `ReportingPhase` tasks are given a closure to report results to the next label up.
 The parameter is a `Result<SuccessValue, Error>`, where `SuccessValue`
 is an associated (~generic) type chosen by the adopter. The `SuccessValue` is returned
 to the closure as a `.success` for the task;  or `.failure` bearing an `Error` to indicate what went wrong.

 * If the task does yield a result, it is passed up to the parent as the `.success()` case of the return.
 * If the task does not yield a result, it wraps an `Error` into the `.failure()` case.

 - note: Not every task produces a concrete result value. In that case, make Success be a
         typealias for `()`, the void.

 Client code need only declare what the `View`'s `SuccessValue` would be, store a
 reference to the closure, and call the closure wherever it might be convenient. When that
 might be or how it got there is an implementation detail so far as the phase next-up is
 concerned.

 The value in `ReportingPhase` is not in any functionality. What it does is to help/enforce
 reasoning about data flow and presentation sequence.
 */
protocol ReportingPhase {
    associatedtype SuccessValue
    typealias ResultValue = Result<SuccessValue,Error>
    typealias ClosureType = (ResultValue) -> Void

    var completion: ClosureType { get }
}
