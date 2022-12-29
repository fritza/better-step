//
//  TopPhases.swift
//  Better Step
//
//  Created by Fritz Anderson on 11/7/22.
//

import Foundation
import SwiftUI

// MARK: - TopPhases

/**
 A `TopPhases` represents a major phase of the application, such as onboarding (`greeting`)  or the two timed walks (`walking`). It is_not_ `OptionSet`.

 There are three levels of sequencing.
 
 - `SeriesTag` identifies the five reporting files. It should not be used for sequencing UI views.
 
 - `TopPhases` identifies the major stage (phase) of the user experience. For example, `walking` stands for the `WalkingContainerView`, which itself manages the sequence of views (instructions, twp walks…) within that topic. A phase may or may not represent any data stream. There are two for walking, one for usability, and none for the greeting phase.
 
 - `WalkingState` is an example of naming sub-tasks within a phase. `WalkingState` includes `countdown_1`, `walk_1`, `interstitial_2`, and so on.  `TopPhases`, which `TopContainerView` uses to name the top-level sequence of phases within the app  is a special case.
 */
struct TopPhases: RawRepresentable, Equatable, CustomStringConvertible {    
    // MARK: AppStorage

    /// The last-ciompleted phase for state restoration. **Belongs at top.**
    @AppStorage(ASKeys.phaseProgress.rawValue) static var latestPhase: String = ""
    ///  The accumulated responses to the DASI Survey. **Move to the DASI phase code.**
//    @AppStorage(ASKeys.collectedDASI.rawValue) static var collectedDASI: Bool =  false
//    /// The accimiulated usability results. **Belongs in `UsabilityContainer`, which BTW should be edited to include the survey form.**
//    @AppStorage(ASKeys.collectedUsability.rawValue) static var collectedUsability: Bool =  false
//
    /// `CustomStringConvertible` adoption.
    var description: String {
        guard let retval = Self.TPAndString
            .first( where: { $0.value == self.rawValue } )
        else { return "{nil}" }
        return retval.value
    }

/*
 I have this terrible problem that I don't know how to address

 "I've never used this before; where do I start?"
 "This is the second time out. Where do I start?"

 The question is what the most-advanced phase is.
 That's the initial state.
 */
/// Restore the completion state (current phase, DASI complete, usability complete) to initial.
    static func resetToFirst() {
        latestPhase = TopPhases.entry.rawValue
        // Static func can't access @AppStorage.
        ASKeys.isFirstRunComplete = false
//        completedFirstRun = false
//        collectedDASI = false
        
//        collectedUsability = false
//        firstUse = true
    }

    /// Restore the completion state as when a first run has been completed (onboarding done).
    static func resetToLater() {
        latestPhase = TopPhases.entry.rawValue
//        collectedDASI = true
//        collectedUsability = true
//        firstUse = false
    }


    // Not an OptionSet, but we'll live.

    /// `RawRepresentable` adoption
    let rawValue: String
    init(rawValue: String) { self.rawValue = rawValue }

    /// Inistantiates a known `TopPhases` from its name. Fails if there is no phase by that name.
    init?(name: String) {
        guard let answer = Self.TPAndString
            .first(where: { $0.value == name} )
        else { return nil }
        self.init(rawValue: name)
    }

    // "Entry" is a pseudo-phase, to give .followingPhase a zero phase to advance from.
    // TODO: for resumption, 
    static let entry      = TopPhases(rawValue: "entry"    )
    // MAYBE instead of

//    static let firstUse   = TopPhases(rawValue: "firstUse"    )
    static let greeting   = TopPhases(rawValue: "greet"       )
    static let onboarding = TopPhases(rawValue: "onboarding"  )
    static let walking    = TopPhases(rawValue: "bothWalks"   )
    static let dasi       = TopPhases(rawValue: "DASI"        )
    static let usability  = TopPhases(rawValue: "usability"   )
    static let conclusion = TopPhases(rawValue: "conclusion"  )
    static let failed     = TopPhases(rawValue: "failed"      )

    /// `String` reoresentations of phases by name.
    fileprivate static let TPAndString: KeyValuePairs<TopPhases, String> = [
//        firstUse   : "firstUse"  ,
        entry      : "entry"     ,

        greeting   : "greet"     ,
        onboarding : "onboarding",
        walking    : "bothWalks" ,
        dasi       : "DASI"      ,
        usability  : "usability" ,
        conclusion : "conclusion",
        failed     : "failed"    ,
    ]
}

// MARK: - Sequencing
extension TopPhases {
    /// The `TopPhases` succeeding  `self`. Returns `nil` if  his ohase has no known successor.
    ///
    /// "No suuccessor" is a sensible response for `conclusion` and `failed`.
    var followingPhase: TopPhases {
        
        
        switch self {
        
        case .entry                 :
//            let subjectIDSet = (SubjectID.id != SubjectID.unSet)
//            return subjectIDSet ? .greeting : .onboarding
            return ASKeys.isFirstRunComplete ? .greeting : .onboarding

        case .greeting, .onboarding: return .walking
        
        case .walking              :
            return ASKeys.isFirstRunComplete ?
                .conclusion : .dasi
        
        case .dasi                 : return .usability
        
        case .usability            : return .conclusion
            // conclusion and failed don't have a next move.
        default                    : return self
        }
    }
}
