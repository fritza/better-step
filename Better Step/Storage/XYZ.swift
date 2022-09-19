//
//  XYZ.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/13/22.
//

import Foundation
import CoreMotion
//import CoreMotion

/// Adopters respond to `csvLine` with all relevant values reduced to `String`s and rendered in a comma-separate list.
public protocol CSVRepresentable {
    /// The salient values of the receiver, rendered as `String`s separated by commas.
    var csvLine: String { get }
}

// MARK: - Timestamped
extension CMLogItem {
    /// Render the timestamp of this element (a `Double` as CSV (one item, no commas)
    ///
    /// - note: This amounts to uwrapping the timestamp and coding it as ``Timestamped``.
    @objc
    public var csvLine: String {
        timestamp.csvLine
    }
}

public protocol Timestamped {
    /// Render a timestamp value, meaning a `String`-formatted `TimeInterval`
    var timestamp: TimeInterval { get }
}

extension Double: CSVRepresentable {
    /// Remder the receiver as a `String` with five digits after the decimal.
    public var csvLine: String { self.pointFive }
}

extension Float: CSVRepresentable {
    /// Remder the receiver as a `String` with five digits after the decimal.
    public var csvLine: String { Double(self).csvLine }
}

extension Int: CSVRepresentable {
    public var csvLine: String { "\(self)"  }
}

extension String: CSVRepresentable {
    /// Render a `String` value by wrapping it in quotation marks.
    public var csvLine: String {
        #""\#(self)""#
    }
}

// MARK: - XYZ
/// Adopters have three `Double` values named `x`, `y`, and `z`.
public protocol XYZ: CSVRepresentable {
    var x: Double { get }
    var y: Double { get }
    var z: Double { get }
}

extension XYZ {
    /// `CSVRepresentable` default: render each component as `Double`, and join them with comma for a separator.
    var csvLine: String {
        [x, y, z].map(\.csvLine).joined(separator: ",")
    }
}


extension Array where Element: CSVRepresentable {
    /// Render the receiver by getting the CSV representations of its components, and joining them all with commas.
    public var csvLine: String {
        let consolidated = self.map { element -> String in
            switch element {
            case is String:
                return element as! String
            default: return element.csvLine
            }
        }
        return consolidated.joined(separator: ",")
    }
}
