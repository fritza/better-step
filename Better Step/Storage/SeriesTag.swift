//
//  SeriesTag.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/14/22.
//

import Foundation


/// Names phases corresponding 1:1 with active user phases, plus a couple of special cases for nullity and the 7-day step record.
///
/// These are for recording user-active progress in `UserDefaults` _only._  Ordering against `sevenDayRecord` or `none` is _undefined_.
public enum SeriesTag: String, Hashable, CaseIterable, Comparable {
    // Possibly CustomStringConvertible.
    // Possibly CaseIterable.

    case firstWalk      = "walk_1"
    case secondWalk     = "walk_2"
    case dasi           = "dasi"
    case usability      = "use"

    case none           = "n/a"
    case sevenDayRecord = "sevenDay"
    
    /// Whether one tag sorts before another,
    /// This is for memorializing the last-completed
    /// user-action phase, set by ``PhaseStorage``..
    public static func < (lhs: SeriesTag, rhs: SeriesTag) -> Bool {
        // Equal is not <
        guard lhs != rhs else { return false }
        
        switch (lhs, rhs) {
            // .none and .sevenDayRecord are always ≤, and == is eliminated.
        case (.none, _), (.sevenDayRecord, _) :
            return true
        case (_, .none), (_, .sevenDayRecord) :
            return false
            
            // Only active phases remain.
            // firstWalk < every non-equal alternative.
            // every non-equal alternative is < usability
        case (.firstWalk, _), (_, .usability):
            return true
            
            // They are both in second/dasi.
            // If lhs is the lower, it's <
        case (.secondWalk, .dasi) : return true
        case (.dasi, .secondWalk) : return false
            
            // All combinations are supposed to have been handled.
        default: fatalError("unhandled comparison between \(lhs.rawValue) and \(rhs.rawValue)")
        }
    }
    
    /// The data-reporting streams to be performed on first run
    public static let neededForFirstRun: Set<SeriesTag> = [
        .firstWalk, .secondWalk,
        .dasi, .usability, .sevenDayRecord
    ]

    /// The data-reporting streams to be performed after first run
    public static let neededForLaterRuns: Set<SeriesTag> = [ .firstWalk, .secondWalk, .sevenDayRecord
    ]

    /// The base name for the `.csv` records file from the subject ID, date, and this phase's prefix code.
    public func dataFileBasename(date: Date = Date()) -> String {
        assert(SubjectID.id != SubjectID.unSet)
        return "\(SubjectID.id)_\(date.ymd)_\(self.rawValue)"
    }

    /// The walk-task sequence code that produces the data for this series.
    ///
    /// For instance, the data-collection task for `firstWalk` is `.walk_1`.
    ///  - returns: The walking task that feeds this phase; or `nil` if the phase does not correspond to any walking task.
    var walkingState: WalkingState? {
        switch self {
        case .firstWalk : return.walk_1
        case .secondWalk: return.walk_2
        default     : return nil
        }
    }

}
