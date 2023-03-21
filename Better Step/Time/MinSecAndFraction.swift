//
//  MinSecAndFraction.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/5/22.
//

import Foundation


/// A _value_ type embodying a minute, second, and fraction-of-seconf for a single moment in time. It translates to clock time only in relation to some starting or ending epoch.
///
/// The expected use is relative to some starting or ending bound to a period of time (coundown or timer). It is not suitable for absolute time, though that _could_ be converted into a `TimeInterval`.
infix operator ≈≈ :  ComparisonPrecedence
struct MinSecAndFraction: Hashable, Comparable,
                          RoughlyEquatable {
    /// The integer-minute component of the moment. Strictly `0 ... 59`.
    let minute  : Int
    /// The integer-second component of the moment. Strictly `0 ... 59`.
    let second  : Int
    ///  The fraction-of-second component of the moment. Strictly `0.0 ..< 1.0`
    let fraction: TimeInterval

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

    /// Create a `MinSecAndFraction` from a time interval relative to an arbitrary epoch.
    /// - Parameter interval: The `TimeInterval` away from the epoch.
    init(interval: TimeInterval) {
        let intInterval = Int(trunc(interval))
        self.init(minute: intInterval / 60,
                  second: intInterval % 60,
                  fraction: interval - trunc(interval))
    }

    /// Whether all components are zero. Prefer this to comparison to `.zero`.
    var isZero: Bool {
        minute == 0 && second == 0 && fraction == 0.0
    }

    /// Whether thie represented interval is at or before the epoch.
    var isPositive: Bool {
        minute >=  0 || second >= 0 || fraction > 0.0
    }

    /// `Comparable` confirmance. Usual warnings about float values not equating well.
    static func < (lhs: MinSecAndFraction, rhs: MinSecAndFraction) -> Bool {
        return lhs.minute < rhs.minute ||
        lhs.second < rhs.second ||
        lhs.fraction < rhs.fraction
    }

    /// `RoughlyEquatable` confirmance. Usual warnings about float values not equating well.
    static func ≈≈ (
        lhs: MinSecAndFraction,
        rhs: MinSecAndFraction) -> Bool {
            let eqMinute: Bool = lhs.minute == rhs.minute
            let eqSecond: Bool = lhs.second == rhs.second
            let leftFrac: TimeInterval = lhs.fraction
            let rightFrac: TimeInterval = rhs.fraction
            let aboutEqFraction: Bool =
            (leftFrac ≈≈ rightFrac)
        return eqMinute && eqSecond && aboutEqFraction
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

}
