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

class WalkInfoResult: ObservableObject, CSVRepresentable, CustomStringConvertible {    
    // Removed per drubin email 3 Jan 2023 deprecating
    // the text fields as too error-prone
    //    @Published var distance           : Int
    //    @Published var lengthOfCourse     : Int?
    @Published var `where`            : WhereWalked
    @Published var howWalked          : HowWalked
    @Published var effort             : EffortWalked
    @Published var fearOfFalling      : Bool
    
    var csvLine: String {
        let values = [`where`.rawValue,
//                      String(distance),
                      howWalked.rawValue,
//                      String(lengthOfCourse ?? 0),
                      effort.rawValue,
                      fearOfFalling ? "Y" : "N"
        ]
        let retval = values.csvLine
        return retval
    }
    
    init() {
       self.`where`        = .atHome
//       self.distance       = 100
       self.howWalked      = .straightLine
//       self.lengthOfCourse = 30
       self.effort         = .somewhat
       self.fearOfFalling  = false
   }

    var description: String {
        var retval = "WalkInfoResult("
        print(self.where, self.howWalked, // self.distance,
              separator: ", ",
              terminator: "",
              to: &retval)
        return retval + ")"
    }

}
