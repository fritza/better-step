//
//  AccelerometerItem.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/13/22.
//

import Foundation
import CoreMotion

/*
 FIXME: Core Motion deals with interval-since-boot time stamps.
        Nothing else does this, and a skim of the system documents
        doesn't show any way to expose it.

 The solution is tedious: The clients want timing as a record-to-record interval, not absolute time. The safest way to capture this is to examine the first element in the record array, capture its stamp, and subtract it from all succeeding records.

 Alternative: capture the start of the exercis, note the time, and calculate it before storage.

 Either way gets us into trouble remembering whether this has been done to the records.
 */


// MARK: - CSVConvertible

/// Adopters convert their data to a CSV stribg
protocol CSVConvertible: Codable, Timestamped {
    /// `Self` rendered into CSV.
    var csv: String { get }
}

// TODO:    For all Accelerometer CSVs, accept CMAcceleration.
// FIXME:   CMAccelerometerData timestamp is epoch last boot,
//          not a fixed epoch, which is what Date usually initializes from.

// MARK: - AccelerometerItem
/// A `Codable`, `Timestamped` representation of `x`, `y`, and `z` acceleration components.
///
/// This is the original representation for a CSV record to be reported to the investigators.
/// Some have wished for the magnitude of the acceleration vector. See `struct MagnitudeItem`.
struct AccelerometerItem: CSVConvertible, XYZ  {
    let x, y, z: Double
    let timestamp: TimeInterval

    /// Initialize from the timestamp and the components of the acceleration vector.
    /// - warning: `CMAccelerometerData` uses a boot-relative timestamp.
    /// - Parameters:
    ///   - stamp: The time the measurement was collected, in seconds since the UNIX epoch. Defaults to the time of initialization.
    ///   - x: The value of the `x` component
    ///   - y: The value of the `y` component
    ///   - z: The value of the `z` component
    init(timestamp: TimeInterval, x: Double, y: Double, z: Double) {
        (self.timestamp, self.x, self.y, self.z) = (timestamp, x, y, z)
    }

    /// Initialize from the vector and timestamp in a `CMAccelerometerData`.
    /// - warning: `CMAccelerometerData` uses a boot-relative timestamp. This will be tricky to get right.
    /// - Parameter accelerometry: A `CMAccelerometerData` from which all components and the timestamp can be calculated.
    init(_ accelerometry: CMAccelerometerData) {
        let acc = accelerometry.acceleration
        self.init(timestamp: accelerometry.timestamp,
                  x: acc.x, y: acc.y, z: acc.z)
    }

    var csv: String {
        let components = [timestamp, x, y, z]
            .map { $0.pointThree }
            .joined(separator: ",")
        return components
    }
}

// TODO: For all Accelerometer CSVs, accept CMAcceleration + the user-supplied stamp.

// MARK: - MagnitudeItem
/// A `Codable`, `Timestamped` representation of the magnitude of the acceleration vector
struct MagnitudeItem: CSVConvertible {
    let magnitude: Double
    let timestamp: TimeInterval

    /// Initialize from the single magnitude of the acceleration vector
    /// - warning: `CMAccelerometerData` uses a boot-relative timestamp.
    /// - Parameters:
    ///   - magnitude: The scalar acceleration
    ///   - stamp: The time the measurement was collected, in seconds since the UNIX epoch. Defaults to the time of initialization.
    init(_ magnitude: Double, stamp: TimeInterval = Date().timeIntervalSince1970) {
        (self.magnitude, timestamp) = (magnitude, stamp)
    }

    /// Initialize from the acceleration vector, as expressed by an `XYZ` value.
    /// - warning: `CMAccelerometerData` uses a boot-relative timestamp.
    /// - Parameters:
    ///   - magnitude: Any `XYZ` value (which carries the separate `x`, `y`, and `z` components.
    ///   - stamp: The time the measurement was collected, in seconds since the UNIX epoch. Defaults to the time of initialization.
    init(_ magnitude: XYZ, stamp: TimeInterval = Date().timeIntervalSince1970) {
        self.init(magnitude.x, y: magnitude.y, z: magnitude.z,
                  stamp: stamp)
    }

    /// Initialize from the acceleration vector, as expressed by its x, y, and z components.
    /// - warning: `CMAccelerometerData` uses a boot-relative timestamp.
    /// - Parameters:
    ///   - magnitude: The `x`, `y`, and `z` components.
    ///   - x: The value of the `x` component
    ///   - y: The value of the `y` component
    ///   - z: The value of the `z` component
    ///   - stamp: The time the measurement was collected, in seconds since the UNIX epoch. Defaults to the time of initialization.
    init(_ x: Double, y: Double, z: Double, stamp: TimeInterval = Date().timeIntervalSince1970) {
        let mag = [x, y, z].map { $0 * $0 }.reduce(0.0, +)
        self.init(sqrt(mag), stamp: stamp)
    }

    var csv: String {
        let components = [timestamp, magnitude]
            .map { $0.pointThree }
            .joined(separator: ",")
        return components
    }
}

