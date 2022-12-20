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
    
    #if DEBUG
    static func sampleData() throws -> [XYZT]? {
        guard let url = Bundle.main
            .url(forResource: "TextXYZT", withExtension: "json")
        else {
            return nil
        }
        let sampleData = try Data(contentsOf: url)
        let xyztArray = try JSONDecoder()
            .decode([XYZT].self, from: sampleData)
        
        return xyztArray
    }
    #endif
}
