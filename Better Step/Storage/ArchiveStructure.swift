//
//  ArchiveStructure.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/12/22.
//

/*
 Yet another archive-structure class (I want all clients to share state) _ought_ to be unnecessary at this stage of the project.

 However, it has only now become clear how to integrate the files-as-Data into Archive files with common code; and to share a consistent date, series, and subject ID; plus file names.
 */


import Foundation
import ZIPFoundation

enum SeriesTag: String, Hashable {
    // Possibly CustomStringConvertible.
    // Possibly CaseIterable.

    case firstWalk      = "walk_1"
    case secondWalk     = "walk_2"
    case dasi           = "dasi"
    case usability      = "use"

    case sevenDayRecord = "sevenDay"

    static let needForFirstRun: Set<SeriesTag> = [
        .firstWalk, .secondWalk,
            .dasi, .use, .sevenDayRecord
        ]
    static let neededForLaterRuns: Set<SeriesTag> = [ .firstWalk, .secondWalk, .sevenDayRecord
        ]
}





final class PhaseStorage
// Possibly an ObservableObject, we'll see.
{
}



