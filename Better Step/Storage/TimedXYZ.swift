//
//  TimedXYZ.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/9/22.
//

import Foundation
import CoreMotion

/// Adoprers present `x`, `y`, `z`, and t as flat properties, and can translate themselves into the minimal ``XYZT`` value.
protocol TimedXYZRepresentable: XYZ & Timestamped & CSVRepresentable {
    /// Reduce the space and time vector to the minimal ``XYZT`` value.
    var asXYZT: XYZT { get }
}

/// Minimal instantiation of space and time coordinates.
///
/// Per compliance with ``TimedXYZRepresentable``, and through that ``CSVRepresentable``, it implements ``asXYZT`` and ``csvLine``.
struct XYZT: TimedXYZRepresentable, CustomStringConvertible {
    let x, y, z, t: Double
    var asXYZT: XYZT { return self }
    var csvLine: String {
        "\(t.pointFour),\(x.pointFive),\(y.pointFive),\(z.pointFive)"
    }
    
    var description: String {
        "XYZT: t: \(t.pointFour), x: \(x.pointFive), y: \(y.pointFive), z: \(z.pointFive)"
    }
}

extension TimedXYZRepresentable {
    // TODO: Do all adopters accept (self as XYZ)
    //       to represent the acceleration-vector
    //       segment of csvLine?

    // This is, I hope, a default implementation that adopters (if identified) can supersede.
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
