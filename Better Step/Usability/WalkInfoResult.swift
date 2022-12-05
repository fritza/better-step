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

struct WalkInfoResult {
    // One ptoblem with private(set) is that callers
    // of .with(_:for:) can't pass a writeable
    // keypath for properties that are locked against
    // the caller.

    /*fileprivate(set)*/ var `where`            : WhereWalked
    /*fileprivate(set)*/ var distance           : Int

    /*fileprivate(set)*/ var howWalked          : HowWalked
    /*fileprivate(set)*/ var lengthOfCourse     : Int?

    /*fileprivate(set)*/ var effort             : EffortWalked
    /*fileprivate(set)*/ var fearOfFalling      : Bool

   init() {
       self.`where`        = .atHome
       self.distance       = 100
       self.howWalked      = .straightLine
       self.lengthOfCourse = 30
       self.effort         = .somewhat
       self.fearOfFalling  = false
   }



   func with<T>(_ path: WritableKeyPath<Self, T>,
                value: T)
    -> WalkInfoResult {
       var retval = self
       retval[keyPath: path] = value
       return retval
   }

}
