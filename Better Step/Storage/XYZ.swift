//
//  XYZ.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/13/22.
//

import Foundation
import CoreMotion
//import CoreMotion

/*
/// Adopters assure that the records in a series have a firsl line naming the fields.
public protocol CSVFileRepresentable {
    static var csvHeaders: [String] { get }

    // TODO: Decide whether to default headerPrefixed(records:) rather than require it
    func headerPrefixed(records: [CSVRepresentable]) -> [String]
}

extension CSVFileRepresentable {
    // TODO: Decide whether to default headerPrefixed(records:) rather than require it

    /// Render an array of csv-representable objects as an array of formatted `String` records.
    /// - Parameter records: An array of csv-representable objects, corresponding to records (e,g, accelerometry readings) in the output file.
    /// - Returns: An array of `String`s, each representing a single data point (or line in the CSV report).
    func headerPrefixed(records: [CSVRepresentable]) -> [String] {

        // Maybe accept a column number for the timestamp
        // value, if any
        // There ought to be in the ultimate (everything after series tag and user ID) array of representables, but does this ever get so fractional lines (sted whole record at a time) get split and come in piecemeal?

//        var headerLine = [Self.csvHeaders.csvLine]
        var initial = Self.csvHeaders.csvLine
        var result: [String] = [initial]

        for record in records {
            let newItem = record.csvLine
            result.append(newItem)
        }

        let retval = records.reduce(into: [Self.csvHeaders.csvLine]) { partialResult, record in
           return partialResult.append(record.csvLine)
        }

        return result
    }
}
*/

/// Adopters respond to `csvLine` with all relevant values reduced to `String`s and rendered in a comma-separated list.
///
/// This has nothing to do with marshalling a whole data series. It does not have a standard prefix (series, subject, timestamp).
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
