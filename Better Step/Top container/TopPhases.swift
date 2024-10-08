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
        /// `CustomStringConvertible` adoption.
    var description: String {
        guard let retval = Self.TPAndString
            .first( where: { $0.value == self.rawValue } )
        else { return "{nil}" }
        return retval.value
    }

    // MARK: AppStorage

    @AppStorage(ASKeys.phaseProgress.rawValue) static var latestPhase: String = ""

    // Not an OptionSet, but we'll live.

    /// `RawRepresentable` adoption
    let rawValue: String
    init(rawValue: String) { self.rawValue = rawValue }

    /// Inistantiates a known `TopPhases` from its name. Fails if there is no phase by that name.
    init?(name: String) {
        guard Self.TPAndString.map(\.value).contains(name) else {
            return nil
        }
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

/// A "pjhase" `View` for anything not among the static valies of ``TopPhases``. Its sole purpose is to provide a `View` to ``TopContainerView`` that has a completion closure bumping the current phase up to `.entry.followingPhase`.
struct EmptyPhase: View, ReportingPhase {
    typealias SuccessValue = Void
    let completion: ClosureType
    
    var body: some View {
        EmptyView()
    }
    
    init(_ completed: @escaping ClosureType) {
        completion = completed
        completion(.success(()))
    }
}
