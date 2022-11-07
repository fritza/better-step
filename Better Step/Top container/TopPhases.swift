//
//  ExTopPhases.swift
//  Better Step
//
//  Created by Fritz Anderson on 11/7/22.
//

import Foundation
import SwiftUI

// MARK: - TopPhases
struct TopPhases: RawRepresentable, Equatable, CustomStringConvertible {

    // MARK: AppStorage
    @AppStorage(ASKeys.phaseProgress.rawValue) static var latestPhase: String = ""
    @AppStorage(ASKeys.collectedDASI.rawValue) static var collectedDASI: Bool =  false
    @AppStorage(ASKeys.collectedUsability.rawValue) static var collectedUsability: Bool =  false

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

    static func resetToFirst() {
        latestPhase = TopPhases.entry.rawValue
        collectedDASI = false
        collectedUsability = false
//        firstUse = true
    }

    static func resetToLater() {
        latestPhase = TopPhases.entry.rawValue
        collectedDASI = true
        collectedUsability = true
//        firstUse = false
    }


    // Not an OptionSet, but we'll live.

    let rawValue: String
    init(rawValue: String) { self.rawValue = rawValue }

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

    static let TPAndString: KeyValuePairs<TopPhases, String> = [
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
    static var firstRunComplete: Bool {
        // "allSatisfy" looks absurd, but maybe kinder to later maintainers.
       return
        [collectedDASI, collectedUsability, SubjectID.id != SubjectID.unSet]
            .allSatisfy( {$0} )
    }

    var followingPhase: TopPhases? {
        switch self {
        case .entry                : return Self.firstRunComplete ? .greeting : .onboarding
        case .greeting, .onboarding : return .walking
        case .walking              :
            return Self.firstRunComplete ?
                .conclusion : .dasi
        case .dasi                 : return .usability
        case .usability            :
            return .conclusion
            // conclusion and failed don't have a next move.
        default                     : return nil
        }
    }


}


/*
enum ExTopPhases: String, CaseIterable, Comparable {

    @AppStorage(ASKeys.collectedDASI.rawValue) var collectedDasi = false


    // Second and further runs. Present a welcome-back screen; chosen by the progress of the one-times? comclusion? failure?
    case greeting

    // Instead of the .greeting. Refers
    case onboarding
    //  `ApplicationOnboardView`.
    //  There are two distinct onboarding tasks:
    //  * New user, greet and collect ID
    //  * detailed explanation (probably different when new)
    case walking

    // TODO: Is "walking" enough?

    case dasi
    case usability
    //    case usabilityForm


    /// Interstitial at the end of the user activities
    case conclusion

    case failed

    //  NOT surveyWrapperView.

    static func < (lhs: ExTopPhases, rhs: ExTopPhases) -> Bool {
        guard lhs.rawValue != rhs.rawValue else{ return false }
        // By here they arent equal.
        // Across all cases, if lhs is the first-encountered,
        // lhs < rhs. If first match is rhs, lhs > rhs.
        for phase in ExTopPhases.allCases {
            if      lhs.rawValue == phase.rawValue { return true }
            else if rhs.rawValue == phase.rawValue { return false }
        }
        return false
    }

    static func == (lhs: ExTopPhases, rhs: ExTopPhases) -> Bool {
        lhs.rawValue == rhs.rawValue
    }

    //    func save() {
    //        let defaults = UserDefaults.standard
    //        defaults.set(rawValue, forKey: "phaseToken")
    //    }

    static let `default`: ExTopPhases = .onboarding
    static func savedPhase() -> ExTopPhases {
        let defaults = UserDefaults.standard
        if let string = defaults.string(forKey: "phaseToken") {
            return ExTopPhases(rawValue: string)!
        }
        return Self.default
    }
}

extension ExTopPhases: CustomStringConvertible {
    static let phaseNames: [ExTopPhases:String] = [
        .conclusion :    "conclusion",
        .onboarding :    "onboarding",
        .dasi       :    "dasi",
        .failed     :    "failed",
        .usability  :    "usability",
        .walking    :    "walking",
    ]

    var description: String {
        return Self.phaseNames[self]!
    }
}

extension ExTopPhases {

    func nextPhase() -> ExTopPhases {
        switch self {
        case .greeting: return .walking
        case .onboarding: return .walking
        case .walking:
            return .dasi


        }
    }
}
*/
