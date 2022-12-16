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
