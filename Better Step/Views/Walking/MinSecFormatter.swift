//
//  MinSecFormatter.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/6/22.
//

import Foundation

// MARK: - MinSecFormatter
public struct MinSecFormatter {
    /// _Global_ flag: If `true`, passing seconds >= 60 to a formatter taking minutes and seconds will throw ``MinSecErrors.secondsOverflow``
    static private let throwSecondsOverflow = false
    // MARK: Errors
    public enum MinSecErrors: Error {
        /// Caller passed a negative number for seconds
        case negativeSeconds
        /// Caller passed a negative number for minutes
        case negativeMinutes
        /// Caller passed seconds >= 60 to a formatter taking minutes and seconds.
        ///
        /// May be overridden if ``Self.throwSecondsOverflow`` is `false` (the default).
        case secondsOverflow
    }

    /// Selector for formatting strategy: If `true`, intervals will be formatted as `mm:ss`; otherwise `s+`.
    let showMinutes: Bool

    /// Create a formatter taking an `Int` time interval and yielding `a String` representing it as either a minutes-seconds pair, or simply the digits of the interval.
    /// - Parameter showMinutes: Time intervals will be represented as minutes and seconds if `true`.
    public init(showMinutes: Bool = true) {
        self.showMinutes = showMinutes
        self.formatStrategy =
        showMinutes ?
        Self.withMinutesStrategy : Self.justSecondsStrategy
    }

    /// A number formatter representing any `NSNumber` as a 2-digit string with leading zero.
    private static let secondsFormatter: NumberFormatter = {
        let retval = NumberFormatter()
        retval.maximumFractionDigits = 0
        retval.minimumFractionDigits = 0
        retval.maximumIntegerDigits  = 2
        retval.minimumIntegerDigits  = 2
        return retval
    }()

    // MARK: Format strategy

    /// Closure taking minutes and seconds and formatting them into a `String`, e.g. `12:34`.
    ///
    /// This is a constant; a `MinSecFormatter` operates one and only one formatter.
    let formatStrategy: (_ minutes: Int, _ seconds: Int) throws -> String

    /// A formatting strategy returning `mm:ss` from integer minutes and seconds.
    ///
    /// This is a constant; a `MinSecFormatter` operates one and only one formatter.
    /// - throws: `MinSecErrors.secondsOverflow` if seconds >= the number of
    ///            seconds in a minute, unless `throwSecondsOverflow` is `false`.
    static func withMinutesStrategy(minutes: Int, seconds: Int) throws -> String {
        guard minutes >= 0 else { throw MinSecErrors.negativeMinutes }
        guard seconds >= 0 else { throw MinSecErrors.negativeSeconds }

        // Throw if the seconds-within-a-minute parameter is
        // 60 or more, unless throwSecondsOverflow is false (default)
        guard !Self.throwSecondsOverflow || seconds < 60 else { throw MinSecErrors.secondsOverflow }

        let mins, secs: Int
        if seconds < 60 {
            mins = minutes; secs = seconds
        }
        else {
            let total = 60*minutes + seconds
            mins = total/60; secs = total%60
        }

        return "\(mins):" +
        Self.secondsFormatter
            .string(from: secs as NSNumber)!
    }

    /// A formatting strategy that renders minutes and seconds as `60 * minutes + seconds` — a single count of seconds.
    ///
    /// This is a constant; a `MinSecFormatter` operates one and only one formatter.
    static func justSecondsStrategy(minutes: Int, seconds: Int) -> String {
        "\(seconds + 60*minutes)"
    }

    // MARK: Formatting
    /// Apply the selected `formatStrategy` to minutes and seconds.
    public func formatted(minutes: Int, seconds: Int) throws -> String {
        try formatStrategy(minutes, seconds)
    }

    /// Apply the selected `formatStrategy` to seconds, taking total seconds rather than minutes and seconds
    public func formatted(seconds: Int) throws -> String {
       try formatted(minutes: seconds / 60,
                     seconds: seconds % 60)
    }
}
