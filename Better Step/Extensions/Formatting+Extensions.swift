//
//  Formatting+Extensions.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/14/22.
//

import Foundation

private let spelledOutFormat: NumberFormatter = {
    let retval = NumberFormatter()
    retval.numberStyle = .spellOut
    return retval
}()

// MARK: - Spelled-out numbers
extension BinaryInteger {
    /// Render a `BinaryInteger` (_e.g._`Int`) as a spelled-out `String`
    var spelled: String {
        let myself: Int = numericCast(self)
        return spelledOutFormat.string(from: myself as NSNumber)!
    }
}

extension BinaryFloatingPoint {
    /// Render a `BinaryFloatingPoint` (_e.g._`Double`) as a spelled-out `String`
    var spelled: String {
        let asSeconds = Int(Double(self).rounded())
        return asSeconds.spelled
    }
}
