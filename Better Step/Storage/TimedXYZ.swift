//
//  TimedXYZ.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/9/22.
//

import Foundation
import CoreMotion

// MARK: - TimedXYZRepresentable
/// Adoprers can type-erase themselves to a value representing only  `x`, `y`, `z`, and `t` coordinates.
///
/// **See also** ``XYZT``
public
protocol TimedXYZRepresentable: XYZ & CSVRepresentable {
    /// Reduce the space and time vector to the minimal ``XYZT`` value.
    var asXYZT: XYZT { get }
}

// MARK: - XYZT
/// Minimal value type for space and time coordinates.
///
/// Consider a type `S where S:Sequence, S.Element: TimedXYZRepresentable`. `Element` might be a reference type. `XYZT` is a value that erases everything but the cordinates.
///
/// **Conforms** to `TimedXYZRepresentable`, etc.
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

// MARK: - Mock instances
extension XYZT {
#if DEBUG
    static func sampleData() throws -> [XYZT]? {
        guard let url = Bundle.main
            .url(forResource: "TestXYZT", withExtension: "json")
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
