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
