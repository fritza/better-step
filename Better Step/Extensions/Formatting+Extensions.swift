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

let _separated: NumberFormatter = {
    let retval                   = NumberFormatter()
    retval.usesGroupingSeparator = true
    retval.groupingSize          = 3
    retval.groupingSeparator     = "_"
    return retval
}()

// MARK: - Spelled-out numbers
extension BinaryInteger {
    /// The integer formatted to be at least two digits long, with leading zeros if necessary.
    /// - warning: This accessor crashes if `self` isn't convertible to `NSNumber`.
    public var twoZeros: String {
        _leadingZeroFmt.string(from: self as! NSNumber)!
    }

    /// Render a `BinaryInteger` (_e.g._`Int`) as a spelled-out `String`
    /// - warning: This accessor crashes if `self` isn't convertible to `NSNumber`.
    var spelled: String {
        let myself: Int = numericCast(self)
        return _spelledFmt.string(from: myself as NSNumber)!
    }

    /// Render a `BinaryInteger`, grouping by thousands with `_` as the delimiter.
    /// - warning: This accessor crashes if `self` isn't convertible to `NSNumber`.
    var separated: String {
        _separated.string(from: self as! NSNumber)!
    }
}

private func numberFormatter(places: Int) -> NumberFormatter {
    let retval = NumberFormatter()
    retval.minimumIntegerDigits   = 1
    retval.minimumFractionDigits  = places
    retval.maximumFractionDigits  = places
    return retval
}

private let _rounded    = numberFormatter(places:  0)
private let _pointThree = numberFormatter(places:  3)
private let _pointFour  = numberFormatter(places:  4)
private let _pointFive  = numberFormatter(places:  5)
private let _pointEight = numberFormatter(places:  8)
private let _pointTen   = numberFormatter(places: 10)


extension BinaryFloatingPoint {
    /// Self to three places after the decimal. Assumes `self` can be force-cast to `NSNumber` and the formatted string is non-nil
    var pointThree: String { _pointThree.string(from: self as! NSNumber)! }
    /// Self to five places after the decimal. Assumes `self` can be force-cast to `NSNumber` and the formatted string is non-nil
    var pointFour: String  { _pointFour .string(from: self as! NSNumber)! }
    /// Self to four places after the decimal. Assumes `self` can be force-cast to `NSNumber` and the formatted string is non-nil
    var pointFive: String  { _pointFive .string(from: self as! NSNumber)! }
    /// Self to eight places after the decimal. Assumes `self` can be force-cast to `NSNumber` and the formatted string is non-nil
    var pointEight: String { _pointEight.string(from: self as! NSNumber)! }
    /// Self to ten places after the decimal. Assumes `self` can be force-cast to `NSNumber` and the formatted string is non-nil
    var pointTen: String   { _pointTen  .string(from: self as! NSNumber)! }
    /// Self rounded to integer. Assumes `self` can be force-cast to `NSNumber` and the formatted string is non-nil
    var rounded: String    { _rounded.string(from: self as! NSNumber)! }
    /// Render a `BinaryFloatingPoint` (_e.g._`Double`) as a spelled-out `String`
    ///
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

extension String {
    /**
     Simple translation of special characters in the string into control characters.
     This makes it easier to put tabs and newlines into configuration strings.

     - `|` (vertical bar) becomes `\n`
     - `^` (caret) becomes `\t`.
     */
    public var addControlCharacters: String {
        let nlLines = self.split(separator: "|", omittingEmptySubsequences: false)
        let nlJoined = nlLines.joined(separator: "\n")

        let tabLines = nlJoined.split(separator: "^", omittingEmptySubsequences: false)
        let tabJoined = tabLines.joined(separator: "\t")

        return tabJoined
    }

    var trimmed: String? {
        let allowable = CharacterSet.alphanumerics
        var working = self
        while let first = working.first {
            if allowable.contains(first.unicodeScalars.last!) {
                break
            }
            working = String(working.dropFirst())
        }

        while let last = working.last {
            if allowable.contains(last.unicodeScalars.last!) {
                break
            }
            working = String(working.dropLast())
        }
        return working.isEmpty ? nil : working
    }
    
    var isAlphanumeric: Bool {
        let allowable = CharacterSet.alphanumerics
        return self.allSatisfy(
            { chr in allowable.contains(chr.unicodeScalars.last!) }
        )
    }
}
