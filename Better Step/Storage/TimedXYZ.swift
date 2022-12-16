//
//  TimedXYZ.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/9/22.
//

import Foundation
import CoreMotion

/// Adoprers present `x`, `y`, `z`, and t as flat properties, and can translate themselves into the minimal ``XYZT`` value.
public
protocol TimedXYZRepresentable: XYZ
//& Timestamped
// I wish I could guarantee a `t` property
// without accepting "timestamp", which is
// what `Timestamped` requires.
// Probably there are generics, or close-cousin
// protocols. I'll try not to think about it.
& CSVRepresentable {
    /// Reduce the space and time vector to the minimal ``XYZT`` value.
    var asXYZT: XYZT { get }
}

/// Minimal instantiation of space and time coordinates.
///
/// Per compliance with ``TimedXYZRepresentable``, and through that ``CSVRepresentable``, it implements ``asXYZT`` and ``csvLine``.
public struct XYZT: TimedXYZRepresentable, CustomStringConvertible, Codable, Hashable {
    public let x, y, z, t: Double
    public var asXYZT: XYZT { return self }
    public var csvLine: String {
        "\(t.pointFour),\(x.pointFive),\(y.pointFive),\(z.pointFive)"
    }
    
   public var description: String {
        "XYZT: t: \(t.pointFour), x: \(x.pointFive), y: \(y.pointFive), z: \(z.pointFive)"
    }
}

extension TimedXYZRepresentable {
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
