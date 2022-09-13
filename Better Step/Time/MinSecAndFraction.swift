//
//  MinSecAndFraction.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/5/22.
//

import Foundation


/// A single struct embodying a minute, second, and fraction for some interval.
public struct MinSecAndFraction: Hashable {
    public let minute  : Int
    public let second  : Int
    public let fraction: TimeInterval

    /// Create a `MinSecAndFraction` from its components.
    /// - Parameters:
    ///   - minute: The truncated number of minutes in the interval
    ///   - second: The truncated number of seconds within the minute
    ///   - fraction: The fraction of the current second, pinned to `(0..<1)`
    /// - note: No attempt is made to validate or reconcile the parameters.
    public init(minute: Int, second: Int, fraction: TimeInterval = 0.0) {
        (self.minute, self.second, self.fraction) =
        (minute, second, fraction)
    }

    public init(interval: TimeInterval) {
        let intInterval = Int(trunc(interval))
        self.init(minute: intInterval / 60,
                  second: intInterval % 60,
                  fraction: interval - trunc(interval))
    }

    /// Whether all components are zero. Prefer this to comparison to `.zero`.
    public var isZero: Bool {
        minute == 0 && second == 0 && fraction == 0.0
    }

    public var isPositive: Bool {
        minute >=  0 || second >= 0 || fraction > 0.0
    }

    /// A copy of this struct with the `fraction` component set to a new value
    /// - Parameter fraction: The `fraction` component for the copy
    /// - Returns: A `MinSecAndFraction` with `self`'s `minute` and `second`, but `fraction` taken from the parameter.
    public func with(fraction: Double) -> MinSecAndFraction {
        return MinSecAndFraction(minute: minute, second: second, fraction: fraction)
    }

    /// The `MinSecAndFraction` that has all zeros for its components.
    public static let zero = MinSecAndFraction(minute: 0, second: 0, fraction: 0.0)
}


extension MinSecAndFraction: CustomStringConvertible {
    /// `CustomStringConvertible` adoption. Displays all three components as in `01:15 + 0.685`.
    public var description: String {
        self.clocked + " + \(self.fraction.pointThree)"
    }

    /// Displays the minute and second  as in `01:15`, no fraction.
    public var clocked: String {
        "\(self.minute.twoZeros):\(self.second.twoZeros)"
    }

    /// The interval written out as it would be spoken. "Minutes" and "seconds" are pluralized as needed; omitted if zero; the return value is `zero` if all components are zero.
    public var spoken: String {
        if self.isZero { return "zero" }
        var partial = ""
        if self.minute > 0 {
            let unitM = (self.minute > 1) ? "minutes" : "minute"
            partial = "\(self.minute) \(unitM)"
        }

        guard self.second != 0 else { return partial }

        if self.second > 0 {
            let unitS = (self.second > 1) ? "seconds" : "second"
            partial += " \(self.second) \(unitS)"
        }
        return partial
    }
}
