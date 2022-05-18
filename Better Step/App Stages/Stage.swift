//
//  Stage.swift
//  Better Step
//
//  Created by Fritz Anderson on 5/11/22.
//

import Foundation
import SwiftUI  // for AppStorage

/*
 Dan also wants a 7-day summary of steps (count) included in the report.
 Prerequisite to reporting, so add a stage:
     .stepRetrieval

 Dan also wants a "post-usability questionnaire", a one-shot, included in the report.
 Prerequisite to reporting, so add a stage:
     .usability

 Apparently a "post-surgery" mode, abbreviated from the full study version of the app.
    Weekly
    subject ID
        no .dasi
        no .usability
    Just the walks.
 This is a different roster of prerequisites.
 */

// MARK: - Stage

/// A set of flags signifying the completion of some stages of the app. The values are preserved in `AppStorage` as an `Int`.
///
/// Set a state as completed by inserting it into the `State` object set. Set incomplete by removing it.
///
///
struct Stage: OptionSet {
    let rawValue: Int
    init(rawValue: Int) { self.rawValue = rawValue }
    init() {
        let defaults = UserDefaults.standard
        let iVal = defaults.integer(
            forKey: AppStorageKeys.completedStages.rawValue)
        self.init(rawValue: iVal)
    }
}

// MARK: - Stage mames
extension Stage {
    static let greeting         = Stage(rawValue:  512)
    /// Completed the `String` identifier for the subject
    /// Once set, this is never cleared.
    static let subjectID        = Stage(rawValue:    1)
    /// Completed the DASI survey
    /// Once set, this is never cleared.
    static let dasi             = Stage(rawValue:    2)

    // TODO: Rationalize the rawValues.
    /// Completed the first timed walk.
    static let walkInstructions = Stage(rawValue:  128)
    static let firstWalk        = Stage(rawValue:    4)
    static let walkInterstitial = Stage(rawValue:    8)
    static let secondWalk       = Stage(rawValue:   16)
    static let walkTerminal     = Stage(rawValue:  256)

    static let stepRetrieval    = Stage(rawValue:  32)
    static let usability        = Stage(rawValue:  64)

    // That leaves room for 81 raw values
    static let prepareReport = Stage(rawValue: 0x100_0000_0000)

    /// One-shot stages, do not repeat after first performance
    static let notClearable: Stage = [.subjectID, .dasi, .usability]
    /// All stages of the physical walk.
    static let allWalks: Stage = [.walkInstructions, .firstWalk, .walkInterstitial, .secondWalk, .walkTerminal]
}
extension Stage {


    func withCompletion(of stage: Stage) -> Stage {
        return self.union(stage)
    }

    func withoutCompletion(of stage: Stage) -> Stage {
#if DEBUG
        let newAsBinary = String(stage.rawValue, radix: 2)
        let selfAsBinary = String(rawValue, radix: 2)
        assert(
            !Self.notClearable.contains(stage),
"""
\(#function) = Stage(rawValue: \(newAsBinary)) cannot be cleared from Stage(rawValue:\(selfAsBinary).
"""
        )
#endif
        return self.subtracting(stage)
    }

    /// Whether the persistent (`UserDefaults`) record indicates a `State` has been accomplished.
    ///
    /// This is useful for extended interstitials like onboarding, subject ID, and first-fime directions for exercises. It may be useful for first and second walk if the flags in `UserDefaults` are cleared upon every return to the app.
    /// - Parameter other: The `State` to be tested for completion.
    /// - Returns: `true` iff the `State` has been completed.
    func meetsCompletion(of other: Stage) -> Bool {
        let intersection = self.intersection(other)
        return intersection == other
    }
}

// MARK: - App-specific conditions
extension Stage {

    static let reportPrerequisites: Stage = [.subjectID, .allWalks, .dasi, .usability, .stepRetrieval]

    /// Whether the `Stage` includes the prerequisites for reporting.
    var isReadyToReport: Bool {
        self.meetsCompletion(of: Self.reportPrerequisites)
    }

    /// Introductory phases are one-shots the subject completes and never sees again.
    ///
    /// `introPhasesComplete` is `true` when all the one-shots have been met.
//    var introPhasesComplete: Bool {
//        self.meetsCompletion(of: .oneShot)
//    }

}

/*
 Requisites.

 These are the tasks necessary for completion of the report.

 These vary between the version's performing usability questionnaire or DASI.

 They vary by whether the one-shot tasks are completed.

 DECIDE, please: different app have different prerequisites.
 Prerequisites within an app depend on whether the one-shots are complete.

 Tabs.
 It's tempting to preserve the badged tags: DASI is still afforded, but if complete, it's badged and leads to a placard saying it's completed.

 "usability" is a one-shot that has to be between the last task (walk or completion of dasi+walk) and the report. Note that it's always after the walk series, if there's any at all.

 So usability is kind of in the family of Report, which should know whether the prerequisites to reporting are completed, and whether the questionnaire is needed.

 But for reconstitution, the "sub"-task of questionnaire has to be known. Incomplete steps (stop in the middle of DASI, divert to walks, DASI between walks) have to be noted.
 */



enum TaskElement {
    /// A single Stage to be completed in the order it appears
    case required(Stage)
    /// The task consists of sub-stages to be completed in-order.
    indirect case sequence([TaskElement])
    /// The task consists of sub-tasks, to be completed in the order desired.
    indirect case set([TaskElement])

    // And then an aggregate, right?

    static func makeSequence(from stages: [Stage]) -> TaskElement {
        let associated: [TaskElement] = stages.map {
            (stage: Stage) -> TaskElement in
          return TaskElement.required(stage)
        }
        return .sequence(associated)
    }

    static func makeSet(from stages: [Stage]) -> TaskElement {
        let associated: [TaskElement] = stages.map {
            (stage: Stage) -> TaskElement in
          return TaskElement.required(stage)
        }
        return .set(associated)
    }
}

/*
 There will be choices made within the elements, such as varying the wording in instructional pages.
 */

let walkSequence = TaskElement.makeSequence(from: [
    .walkInstructions, .firstWalk, .walkInterstitial, .secondWalk, .walkTerminal
])

let firstRunFullAppTask: [TaskElement] = [
    TaskElement.makeSequence(from: [.greeting, .subjectID]),
    TaskElement.set(
        [.required(.dasi), walkSequence]),
    TaskElement.required(.usability),
    TaskElement.required(.prepareReport),
    // Somewhere in here, collect the stepRetrieval.
]

let firstRunFullElement = TaskElement.sequence(firstRunFullAppTask)

let laterRunFullAppTask: [TaskElement] = [
    .required(.greeting),
    // TaskElement.required(.subjectID),
    walkSequence,
    TaskElement.required(.prepareReport),
    // Somewhere in here, collect the stepRetrieval.
]
let laterRunFullElement = TaskElement.sequence(laterRunFullAppTask)

/// Determine whether a `Stage` is within a `TaskElement` (scalar or aggregate). This is  a deep search
/// - Parameters:
///   - taskElement: The task tree to search
///   - stage: The progress stage to search for
/// - Returns: `nil` if the `Stage` wasn't found, otherwise the `.required` node that wraps it.
/// - note: **This isn't very useful** if you want the node _following_ the one you find.
/// - precondition: All `Stage` leaves are unique within the tree.
func element(_ taskElement: TaskElement, contains stage: Stage) -> TaskElement? {
    switch taskElement {
    case .required(let rStage):
        // You've found the leaf task you're looking for.
        // It doesn't tell you what the next task is.
        return (stage == rStage) ? taskElement : nil

    case .sequence(let list):
        precondition(!list.isEmpty, "\(#function):\(#line) - empty aggregate task node")
        for elem in list {
            if let e = element(elem, contains: stage) {
                // How about you traverse all the leaves beforehand, recursive descent?
                // The reduction of .required is the aux value itself.
                // The reduction of .sequence is the ordered list of the leaves under it.
                // HOWEVER, the .sets are different. On those branches, the descendants may be visited in any order.
                //      BUT the ordering within them is mandatory, unless they themselves have sets.
                //
                // Oh, and if there's an option, each option tree (dasi or walk) can be left hanging because the other's tab has been tapped.
                //
                // The tabs can be associated with the indices out of the respective subtrees.
                // But incompleted subtrees…
                //      … what's "next" in them? Or out of them?
                // So any location in the tree can be identified by IndexPath. In a sequence, the "next" is a matter of incrementing the trailing index, returning (refusing) when those run out, and the upstream handlers can increment the last item as well.
                // That's restorable. You can even index Stage <-> path.
                // But IndexPath elements are strictly sequential.
                //      BTW, below a Set node, "next" may mean dropping down to the next choice.
                // In the indexing tree, maybe there ought to be nodes that cover the current index into the respective branches (simultaneously). (Stage, index) <- trivial if a strict index path. [(Stage, index), (Stage, index)...] to preserve paths into options.
                return e
            }
        }
        return nil
    case .set(let list):
        precondition(!list.isEmpty, "\(#function):\(#line) - empty aggregate task node")
        for elem in list {
            if let e = element(elem, contains: stage) {
                return e
            }
        }
        return nil
    default:
        return nil
    }
    return nil
}

func whatsNext(after current: Stage, in taskList: TaskElement) -> [Stage] {


    // Walk the taskList to find the current stage.
    // If the stage is a
    // If it's required within a SEQUENCE, look
    //  at the containing collection and return the next one unused.

    return [.greeting]
}

