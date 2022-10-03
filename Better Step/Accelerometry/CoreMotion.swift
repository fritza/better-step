//
//  CoreMotion.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/14/22.
//

import Foundation
import Collections
import CoreMotion
import SwiftUI

// MARK: Time intervals

enum CMTimeInterval {
    static let hz                : UInt64 = 120
    static let hzInterval        : Double = 1.0/Double(hz)
    static let nanoSleep         : UInt64 = UInt64(hzInterval * Double(NSEC_PER_SEC))
    // TODO: Consider putting the interval in a UserDefault.

    static let secondsInBuffer   : UInt64 = 2
    static let minBufferCapacity : UInt64 = secondsInBuffer * hz * 2
}

// FIXME: Figure out how to collect for a new subject.
//        That is, you may not be killing this app before a second subject arrives to take a new test. The loop-exhaustion process forecloses a restart in-place.
//  Can you replace `.shared`?


// MARK: - Available / Active
/// Wrapper for the availability and activity of some facility.
protocol Availability {
    var cmManager: CMMotionManager { get }
    var available: Bool { get }
    var active   : Bool { get }
}

/// Availability (has any Core Motion and active status for the device
struct DeviceState: Availability {
    private(set) var cmManager: CMMotionManager

    init(_ manager: CMMotionManager) {
        self.cmManager = manager
    }

    var available: Bool {
        cmManager.isDeviceMotionAvailable
    }
    var active   : Bool  {
        cmManager.isDeviceMotionActive
        }
}

/// Availability (has accelerometers) and active status (collecting) for the inertial platform
struct AccelerometerState: Availability {
    private(set) var cmManager: CMMotionManager

    init(_ manager: CMMotionManager) {
        self.cmManager = manager
    }

    var available: Bool {
        cmManager.isAccelerometerAvailable
        }
    var active   : Bool  {
        cmManager.isAccelerometerActive
        }
}


// MARK: - MotionManager
/// Wrapper around `CMMotionManager` with convenient start / stop / `AsyncSequence` for accelerometry,
///
/// - bug: It's not obvious how to start the accelerometers independently of generating sequence elements.
final class MotionManager {
    /// Access to the singleton `MotionManager`.
    ///
    /// - bug: A single instance can't be restarted for a new walk. Add a way to replace `Self.shared`.

    // MARK: Properties

    static let shared = MotionManager()
    static var census = 0

    var lastTimeStamp: TimeInterval = -TimeInterval.infinity

    let motionManager: CMMotionManager
    private let deviceState : DeviceState
    private let accState: AccelerometerState
    var isCancelled: Bool = false

    typealias CMDataStream = AsyncStream<CMAccelerometerData>
    var stream: CMDataStream!

    let asyncBuffer = IncomingAccelerometry()
//    func count() -> Int { return asyncBuffer.count }

    // MARK: - Initialization and start
    init() {
        let cmManager = CMMotionManager()
        cmManager.accelerometerUpdateInterval = CMTimeInterval.hzInterval
        motionManager = cmManager

        deviceState = DeviceState(cmManager)
        accState = AccelerometerState(cmManager)
    }

    var accelerometryAvailable: Bool {
        accState.available
    }

    var accelerometryActive: Bool {
        accState.active
    }
}
