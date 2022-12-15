//
//  TimedXYZ.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/9/22.
//

import Foundation
import CoreMotion

protocol TimedXYZRepresentable: XYZ & Timestamped & CSVRepresentable {
}

extension TimedXYZRepresentable {
    // TODO: Do all adopters accept (self as XYZ)
    //       to represent the acceleration-vector
    //       segment of csvLine?

    public var csvLine: String {
        let vectorPart: String = (self as XYZ).csvLine
        // vectorPart carries the elements as .pointFive;
        // that's the specification for accelerations.

        // Time intervals are to be .pointFour, which must
        // be specially formatted.
        let timingPart = timestamp.pointFour
        return "\(timingPart),\(vectorPart)"
    }

    /// Convenience method for assembling a full record in an accelerometry report.
    /// - Parameters:
    ///   - seriesTag: The “tag” string identifying the record series: “`walk_1`”,“`walk_2`”, etc.)
    ///   - subjectID: The unique ID of the subject observed in the study.
    /// - Returns: A CSV line representing series, subject, time, x, y, and z.
    public func wholeAccelerometryLine() -> String {
        self.csvLine
    }
#warning("Replace with .csvLine")
}

/// Renders time-x-y-z vectors as fields for a CSV record.
///
/// `CMFlattened` may be initialized with separate component values, or with convenience methods that take `XYZ` or `CMAccelerometryData`.
///
/// Callers supply the time component explicitly, or omitting it for `0.0`, or implicitly from `CMAccelerometerData`.
public struct CMFlattened: TimedXYZRepresentable, CSVRepresentable, CustomStringConvertible {
    public let x, y, z, timestamp: Double

    /// Initialize from all scalar component values.
    /// - parameters:
        /// - xParam: The _x_ component
        /// - yParam: The _y_ component
        /// - zParam: The _z_ component
        /// - time: : The _time_ component; defaults to 0..0
    public init(_ xParam: Double, _ yParam: Double, _ zParam: Double,
         time: TimeInterval = 0.0) {
        (self.x, self.y, self.z) = (xParam, yParam, zParam)
        self.timestamp = time
    }

    /// Initialize from a `CMAccelerometerData`, which includes a timestamp
    /// - Parameter cmAcc: The Core Motion time-stamped vetor
    public init(acceleration cmAcc: CMAccelerometerData) {
        self.init(vector: cmAcc.acceleration,
                  timestamp: cmAcc.timestamp)
    }

    /// nitialize from the scalar components of an `XYZ`, additionally accepting a timestamp.
    /// - Parameters:
    ///   - vector: The x, y, and z components of the acceleration vector
    ///   - timestamp: The time at which the vector was observed
    public init(vector: XYZ, timestamp: TimeInterval = 0.0) {
        self.init(vector.x, vector.y, vector.z,
                  time: timestamp)
    }

    /// A `CMFlattened` with all components set to `0.0`.
    public static let zero = CMFlattened(0.0, 0.0, 0.0, time: 0.0)

    public var csvLine: String {
        let vectorPart: String = (self as XYZ).csvLine
        // vectorPart carries the elements as .pointFive;
        // that's the specification for accelerations.

        // Time intervals are to be .pointFour, which must
        // be specially formatted.
        let timingPart = timestamp.pointFour
        return "\(timingPart),\(vectorPart)"
    }

    public var description: String {
        "CMFlattened(x: \(x.pointFour), y: \(y.pointFour), z: \(z.pointFour), t: \(timestamp.pointFive))"
    }

    public static let headerLine: String = {
        ["series", "subject", "t", "x", "y", "z"]
            .csvLine
    }()
}


