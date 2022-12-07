//
//  FloatEquatable.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/12/22.
//

import Foundation

infix operator ≈≈  : ComparisonPrecedence
infix operator !≈≈ : ComparisonPrecedence

/// Adopters respond whether two instances are _almost_ equal.
///
/// For `BinaryFloatingPoint` numbers, ≈≈ succeeds if the difference between the operands is less than ε (defined in this source) as a proportion of the greater.
/// - note: The operator is a pair of the "approximately equal" character (`≈`,  **⌥X **on EN\_us keyboard). Most monofonts do not make this clear,
public protocol RoughlyEquatable {
    static func ≈≈ (lhs: Self, rhs: Self) -> Bool
}

extension RoughlyEquatable {
    ///  `!≈≈` is the negation of `≈≈`
    public static func !≈≈ (lhs: Self, rhs: Self) -> Bool {
        !(lhs ≈≈ rhs)
    }
}

extension Double  : RoughlyEquatable {
    public static func ≈≈ (lhs: Double, rhs: Double) -> Bool {
        guard lhs != rhs else { return true }

        var (low, high) = (lhs, rhs)
        if abs(low) > abs(high) { (low, high) = (high, low) }

        let wing = ε * abs(high)
        let range = (high-wing)...(high+wing)
        return range.contains(low)
    }
}
extension Float32 : RoughlyEquatable { }
#if os(macOS)
extension Float80 : RoughlyEquatable { }
#endif

fileprivate let ε = 1.0e-3

extension BinaryFloatingPoint {
    /// Whether two floating-point values are “roughly” equal.
    ///
    /// This is defined as being within ε \* greater magnitde  of each other
    public static func ≈≈ (lhs: Self, rhs: Self) -> Bool {
        return Double(lhs) ≈≈ Double(rhs)
    }
}


