//
//  PhaseStorage.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/12/22.
//

/*
 Yet another archive-structure class (I want all clients to share state) _ought_ to be unnecessary at this stage of the project.

 However, it has only now become clear how to integrate the files-as-Data into Archive files with common code; and to share a consistent date, series, and subject ID; plus file names.
 */

/*
 Who should do the file names?
 Can we see if we can leave CSVArchiver alone for that?
 */


import Foundation
import ZIPFoundation



/// Maintain the data associated with completed phases of the workflow.
///
/// Watch completion of all necessary stages by observing `.isComplete`.
public final class PhaseStorage: ObservableObject
{
    public enum CompletionGoal {
        case firstRun
        case secondRun
    }

    typealias CompDict = [SeriesTag:Data]
    private var completionDictionary: CompDict
    private var goal                : CompletionGoal
    public  var isComplete          : Bool

    public init(goal: CompletionGoal) {
        completionDictionary = [:]
        self.goal = goal
        self.isComplete = false
    }


    private func checkCompletion() {
        // Do all of what I've finished...
        let finishedKeys = Set(completionDictionary.keys)
        // appear in the list of what should be finished?
        let superset = (goal == .firstRun) ? SeriesTag.needForFirstRun : SeriesTag.needForFirstRun
        let isCompeted = finishedKeys.isSubset(of: superset)
        isComplete = isCompeted
    }


    public func series(_ tag: SeriesTag, completedWith data: Data) {
        guard !completionDictionary.keys.contains(tag) else {
            preconditionFailure("\(#function) - Attempt to re-insert \(tag.rawValue)")
        }
        completionDictionary[tag] = data
        checkCompletion()
    }

}



//    var completed: Bool {
//        // Do all of what I've finished...
//        let finishedKeys = Set(completionDictionary.keys)
//        // appear in the list of what should be finished?
//        let superset = (goal == .firstRun) ? SeriesTag.needForFirstRun : SeriesTag.needForFirstRun
//        return finishedKeys.isSubset(of: superset)
//    }
