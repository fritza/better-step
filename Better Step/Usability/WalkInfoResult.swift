//
//  WalkInfoResult.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/5/22.
//

import Foundation


enum WhereWalked: String, Hashable {
    case atHome, awayFromHome
}

enum HowWalked: String, Hashable {
    case straightLine, backAndForth
}

enum EffortWalked: String, Hashable, CaseIterable {
    case light, somewhat, hard
    case veryHard = "Very Hard"
}

class WalkInfoResult: ObservableObject, CustomStringConvertible {
    @Published var `where`            : WhereWalked
    @Published var distance           : Int
    @Published var howWalked          : HowWalked
    @Published var lengthOfCourse     : Int?
    @Published var effort             : EffortWalked
    @Published var fearOfFalling      : Bool

   init() {
       self.`where`        = .atHome
       self.distance       = 100
       self.howWalked      = .straightLine
       self.lengthOfCourse = 30
       self.effort         = .somewhat
       self.fearOfFalling  = false
   }

    var description: String {
        var retval = "WalkInfoResult("
        print(self.where, self.howWalked, self.distance,
              separator: ", ",
              terminator: "",
              to: &retval)
        return retval + ")"
    }

}
