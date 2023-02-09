//
//  SeriesTag.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/14/22.
//

import Foundation

/// Names phases corresponding 1:1 with the reported data streams.
///
/// These name
public enum SeriesTag: String, Hashable, CaseIterable {
    // Possibly CustomStringConvertible.
    // Possibly CaseIterable.

    case firstWalk      = "walk_1"
    case secondWalk     = "walk_2"
    case dasi           = "dasi"
    case usability      = "use"

    case sevenDayRecord = "sevenDay"

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
