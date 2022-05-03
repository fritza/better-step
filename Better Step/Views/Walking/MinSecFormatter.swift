//
//  MinSecFormatter.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/6/22.
//

import Foundation

// MARK: - MinSecFormatter
// FIXME: This isn't actually used.
//        Examine MinutePublisher to see whether it could benefit from changing over.
public struct MinSecFormatter {
    static private let throwSecondsOverflow = false
    // MARK: Errors
    public enum MinSecErrors: Error {
        case negativeSeconds
        case negativeMinutes
        case secondsOverflow
    }
    let showMinutes: Bool

    public init(showMinutes: Bool = true) {
        self.showMinutes = showMinutes
        self.formatStrategy =
        showMinutes ?
        Self.withMinutesStrategy : Self.justSecondsStrategy
    }

    private static let secondsFormatter: NumberFormatter = {
        let retval = NumberFormatter()
        retval.maximumFractionDigits = 0
        retval.minimumFractionDigits = 0
        retval.maximumIntegerDigits  = 2
        retval.minimumIntegerDigits  = 2
        return retval
    }()

    // MARK: Format strategy
    // FIXME: Why should any of this throw?
    //        Maybe some should return String?, some subject to a precondition check.
    let formatStrategy: (_ minutes: Int, _ seconds: Int) throws -> String
    static func withMinutesStrategy(minutes: Int, seconds: Int) throws -> String {
        guard minutes >= 0 else { throw MinSecErrors.negativeMinutes }
        guard seconds >= 0 else { throw MinSecErrors.negativeSeconds }
        guard !Self.throwSecondsOverflow || seconds < 60 else { throw MinSecErrors.secondsOverflow }

        // If there's a seconds overflow,
        // and throwSecondsOverflow permits,
        // renorm minutes and seconds to a proper time interval
        let mins, secs: Int
        if seconds < 60 {
            mins = minutes
            secs = seconds
        }
        else {
            let total = 60*minutes + seconds
            mins = total/60
            secs = total%60
        }

        return "\(mins):" +
        Self.secondsFormatter
            .string(from: secs as NSNumber)!
    }

    static func justSecondsStrategy(minutes: Int, seconds: Int) -> String {
        "\(seconds + 60*minutes)"
    }

    // MARK: Formatting
    public func formatted(minutes: Int, seconds: Int) throws -> String {
        try formatStrategy(minutes, seconds)
    }

    public func formatted(seconds: Int) throws -> String {
       try formatted(minutes: seconds / 60,
                     seconds: seconds % 60)
    }
}
