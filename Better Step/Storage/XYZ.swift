//
//  XYZ.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/13/22.
//

import Foundation
//import CoreMotion


// MARK: - Timestamped
public protocol Timestamped {
    var timestamp: TimeInterval { get }
}

// MARK: - XYZ
public protocol XYZ {
    var x: Double { get }
    var y: Double { get }
    var z: Double { get }
}

