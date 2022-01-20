//
//  AccelerometerItem.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/13/22.
//

import Foundation
import CoreMotion

private let _pointThree: NumberFormatter = {
    let retval = NumberFormatter()
    retval.minimumIntegerDigits = 1
    retval .minimumFractionDigits = 3
    retval.maximumFractionDigits  = 3
    return retval
}()

extension BinaryFloatingPoint {
    var pointThree: String {
        _pointThree.string(from: self as! NSNumber)!
    }
}

struct AccelerometerItem: Codable, Timestamped, XYZ  {
    let x, y, z: Double
    let timestamp: TimeInterval

    enum CodingKeys: String, CodingKey {
        case x, y, z, timestamp
    }

    init(timestamp: TimeInterval, x: Double, y: Double, z: Double) {
        (self.timestamp, self.x, self.y, self.z) = (timestamp, x, y, z)
    }

    init(_ accelerometry: CMAccelerometerData) {
        let acc = accelerometry.acceleration
        self.init(timestamp: accelerometry.timestamp,
                  x: acc.x, y: acc.y, z: acc.z)
    }
}

extension AccelerometerItem {
    var csv: String {
        let components = [timestamp, x, y, z]
            .map { $0.pointThree }
            .joined(separator: ",")
        return components
    }
}

