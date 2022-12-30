//
//  XYZ.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/13/22.
//

import Foundation
import CoreMotion

/// Adopters respond to `csvLine` with all relevant values reduced to `String`s and rendered in a comma-separated list.
///
/// This has nothing to do with marshalling a whole data series. It does not have a standard prefix (series, subject, timestamp).
public protocol CSVRepresentable {
    /// The salient values of the receiver, rendered as `String`s separated by commas.
    var csvLine: String { get }
}

extension CSVRepresentable {
    var csvData: Data {
        guard let data = csvLine.data(using: .utf8) else {
            fatalError("can't derive data from \(csvLine)")
        }
        return data
    }
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
    ///
    /// Note: The intended use of floating `CSVRepresentable` is for elements of an acceleration vector, which is required to have exactly five decimal places.
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
    public var csvLine: String {
        [x, y, z]
            .map(\.pointFive)
            .map(\.csvLine)
            .joined(separator: ",")
    }
}

struct AnyCSVRepresentable
//<CSV: CSVRepresentable>
: CSVRepresentable
{
    private let base: any CSVRepresentable
    
    init<T:CSVRepresentable>(_ baseValue: T) {
        base = baseValue
    }
    var csvLine: String {
        base.csvLine
        //        (base as! CSVRepresentable).csvLine
    }
}

extension CSVRepresentable {
    func eraseToAny() -> AnyCSVRepresentable /*<Self>*/ {
        return AnyCSVRepresentable(self)
    }
}

extension Array where Element: CSVRepresentable {
    public var csvLine: String {
        guard !self.isEmpty else { return "" }
        let representables = self.map(\.csvLine)
            .joined(separator: ",")
        return representables
    }
}
