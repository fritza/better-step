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

private let _pointThree: NumberFormatter = {
    let retval = NumberFormatter()
    retval.minimumIntegerDigits = 1
    retval .minimumFractionDigits = 3
    retval.maximumFractionDigits  = 3
    return retval
}()

extension BinaryFloatingPoint {
    var pointThree: String {
        _pointThree.string(from: self as! NSNumber)!
    }
    /// Render a `BinaryFloatingPoint` (_e.g._`Double`) as a spelled-out `String`
    var spelled: String {
        let asSeconds = Int(Double(self).rounded())
        return asSeconds.spelled
    }
}

private let isoFormatter: ISO8601DateFormatter = {
    let retval = ISO8601DateFormatter()
    retval.formatOptions = .withInternetDateTime
    return retval
}()

extension Date {
    public var iso: String {
        isoFormatter.string(from: self)
    }
}
