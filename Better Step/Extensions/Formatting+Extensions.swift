//
//  Formatting+Extensions.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/14/22.
//

import Foundation

private let _leadingZeroFmt: NumberFormatter = {
    let retval = NumberFormatter()
    retval.minimumIntegerDigits = 2
    retval.maximumFractionDigits = 0
    return retval
}()

let _spelledFmt: NumberFormatter = {
    let retval = NumberFormatter()
    return retval
}()

// MARK: - Spelled-out numbers
extension BinaryInteger {
    /// The integer formatted to be at least two digits long, with leading zeros if necessary.
    public var twoZeros: String {
        _leadingZeroFmt.string(from: self as! NSNumber)!
    }

    /// Render a `BinaryInteger` (_e.g._`Int`) as a spelled-out `String`
    var spelled: String {
        let myself: Int = numericCast(self)
        return _spelledFmt.string(from: myself as NSNumber)!
    }
}

private func numberFormatter(places: Int) -> NumberFormatter {
    let retval = NumberFormatter()
    retval.minimumIntegerDigits = 1
    retval .minimumFractionDigits = places
    retval.maximumFractionDigits  = places
    return retval
}

private let _rounded    = numberFormatter(places: 0)
private let _pointThree = numberFormatter(places: 3)
private let _pointFive  = numberFormatter(places: 5)
private let _pointEight = numberFormatter(places: 8)
private let _pointTen   = numberFormatter(places: 10)


extension BinaryFloatingPoint {
    /// Self to three places after the decimal. Assumes `self` can be force-cast to `NSNumber` and the formatted string is non-nil
    var pointThree: String { _pointThree.string(from: self as! NSNumber)! }
    /// Self to five places after the decimal. Assumes `self` can be force-cast to `NSNumber` and the formatted string is non-nil
    var pointFive: String  { _pointFive .string(from: self as! NSNumber)! }
    /// Self to eight places after the decimal. Assumes `self` can be force-cast to `NSNumber` and the formatted string is non-nil
    var pointEight: String { _pointEight.string(from: self as! NSNumber)! }
    /// Self to ten places after the decimal. Assumes `self` can be force-cast to `NSNumber` and the formatted string is non-nil
    var pointTen: String   { _pointTen  .string(from: self as! NSNumber)! }
    /// Self rounded to integer. Assumes `self` can be force-cast to `NSNumber` and the formatted string is non-nil
    var rounded: String   { _rounded.string(from: self as! NSNumber)! }
    /// Render a `BinaryFloatingPoint` (_e.g._`Double`) as a spelled-out `String`
    var spelled: String {
        let asSeconds = Int(Double(self).rounded())
        return asSeconds.spelled
    }
}

private let _isoFormatter: ISO8601DateFormatter = {
    let retval = ISO8601DateFormatter()
    retval.formatOptions = .withInternetDateTime
    return retval
}()

extension Date {
    public var iso: String {
        _isoFormatter.string(from: self)
    }

    /// The midnight commencing the year 1960 UTC. Sometimes used as an epoch date.
    static let y1960: Date = {
        let gregorian = Calendar(identifier: .gregorian)
        let components = DateComponents(
            calendar: gregorian,
            timeZone: TimeZone(abbreviation: "GMT"),
            year: 1960)
        guard let y1960 = gregorian.date(from: components) else {
            fatalError("\(#function) - couldn't get date since 1960.")
        }
        return y1960
    }()

    /// The date expressed as a time interval from the 1960 epoch.
    public var timeIntervalSince1960: TimeInterval {
        return Date().timeIntervalSince(Self.y1960)
    }
}
