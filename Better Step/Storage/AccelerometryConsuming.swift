//
//  AccelerometryConsuming.swift
//  G Bars
//
//  Created by Fritz Anderson on 9/9/22.
//

import Foundation
import CoreMotion

/// ## Topics
///
/// ### Properties
/// - ``timestamp``
/// - ``acceleration``
/// - ``csvLine

/// Adopters provide getters for the properties of `CMAccelerometerData` (`timestamp` and `acceleration`). Allows for initializable equivalents suitable for testing.
protocol AccelerometerDataContent: NSObject & CSVRepresentable {
    /// The time recorded, in `TimeInterval` since an epoch related to restart time.
    var timestamp: TimeInterval { get }
    /// The observed forces in G.
    var acceleration: CMAcceleration { get }
}

extension AccelerometerDataContent {
    /// `CSVRepresentable` adoption
    var csvLine: String {
        let asString = [timestamp, acceleration.x, acceleration.y, acceleration.z]
            .map(\.pointFive)
            .joined(separator: ",")
        return asString
    }
}

extension CMAccelerometerData: AccelerometerDataContent {}

/// ## Topics
///
/// ### Initialization
/// - ``init(timestamp:acceleration)``
/// - ``init(t:x:y:z:)``
///
/// ### Properties
/// - ``csvLine``
/// - ``timestamp``
/// - ``acceleration``

// MARK: - CMAccelerometerData (content) (CSV)
extension CMAccelerometerData: CSVRepresentable {
    /// Represent acceleration and timestamp as fields in a CSV record.
    public override var csvLine: String {
        let asString = [timestamp, acceleration.x, acceleration.y, acceleration.z]
            .map(\.pointFive)
            .joined(separator: ",")
        return asString
    }
}

// MARK: - AccelerometryConsuming

/// ## Topics
/// ### Recording
/// - ``append(_:)``
/// - ``append(contentsOf:)``
/// - ``allRecords()``
/// - ``marshalledRecords()``

/// ### Properties
/// - ``csvLine``
/// - ``timestamp``
/// - ``acceleration``

/// Adopters can accept `AccelerometerDataContent` elements and do simple reductions to `[String]`.
///
/// Basically, an array, but could be a writeable `FileHandle`
protocol AccelerometryConsuming {
    /// Add the accelerometer observation to the list
    func append(_ record: AccelerometerDataContent)
    /// Add multiple accelerometer observations to the list.
    func append(contentsOf array: [AccelerometerDataContent])
    /// The accumulated list of observations as an `Array`
    func allRecords() -> [AccelerometerDataContent]
    /// `Array` of the observations, rendered as CSV
    func marshalledRecords() -> [String]
}

// MARK: Default implementation
extension AccelerometryConsuming {
    /// Default implementation of required `append(contentsOf:)`
    func append(contentsOf array: [CMAccelerometerData]) {
        for datum in array { self.append(datum) }
    }

    // Adopters should definitely override this,
    // especially when the ad-interim store is a file.
    /// Default implementation of required `marshalledRecords()`
    func marshalledRecords() -> [String] {
        let all = self.allRecords()
        let strings = all.map(\.csvLine)
        return strings
    }
}

