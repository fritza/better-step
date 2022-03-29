//
//  CoreMotion+extensions.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/28/22.
//

import Foundation

import CoreMotion

extension CMAcceleration: CustomStringConvertible {
    public var description: String {
        "Acc(\(x.pointThree), \(y.pointThree), \(z.pointThree))"
    }

    public static func + (lhs: CMAcceleration, rhs: CMAcceleration) -> CMAcceleration {
        CMAcceleration(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }

    public static func - (lhs: CMAcceleration, rhs: CMAcceleration) -> CMAcceleration {
        CMAcceleration(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }

    public static prefix func - (lhs: CMAcceleration) -> CMAcceleration {
        CMAcceleration(x: -lhs.x, y: -lhs.y, z: -lhs.z)
    }

    public static func / (lhs: CMAcceleration, divisor: Double) -> CMAcceleration {
        CMAcceleration(x: lhs.x/divisor, y: lhs.y/divisor, z: lhs.z/divisor)
    }

    public static func / (lhs: CMAcceleration, divisor: Int) -> CMAcceleration {
        lhs / Double(divisor)
    }

    static let zero = CMAcceleration(x: 0.0, y: 0.0, z: 0.0)
}
