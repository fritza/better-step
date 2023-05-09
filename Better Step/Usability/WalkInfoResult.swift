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

enum EffortWalked: String, Hashable, CaseIterable, Identifiable {
    case light, somewhat, hard
    case veryHard = "Very Hard"

    var label: String {
        self.rawValue.capitalized
    }
    var id: String { rawValue }
}

class WalkInfoResult: ObservableObject, CSVRepresentable, CustomStringConvertible {    
    // Removed per drubin email 3 Jan 2023 deprecating
    // the text fields as too error-prone
    //    @Published var distance           : Int
    //    @Published var lengthOfCourse     : Int?
    @Published var `where`            : WhereWalked
    //{        didSet { print("WIR: where changed from \(oldValue) to \(`where`)")
//        }
//    }
    @Published var howWalked          : HowWalked
    @Published var effort             : EffortWalked
    @Published var fearOfFalling      : Bool
    
    var csvLine: String {
        let values = [`where`.rawValue,
                      howWalked.rawValue,
                      effort.rawValue,
                      fearOfFalling ? "Y" : "N"
        ]
        let retval = values.csvLine
        return retval

        //   String(lengthOfCourse ?? 0),
        //   String(distance),
    }
    
    init() {
       self.`where`        = .atHome
       self.howWalked      = .straightLine
       self.effort         = .light
       self.fearOfFalling  = false
    }

        //       self.distance       = 100
        //       self.lengthOfCourse = 30

    var description: String {
        var retval = "WalkInfoResult("
        print("where: \(self.where)",
              "how: \(self.howWalked)",
              "fear: \(self.fearOfFalling)",
              "effort: \(self.effort)",
              // self.distance,
              separator: ", ",
              terminator: "",
              to: &retval)
        return retval + ")"
    }

}
