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
////    static let hz                : UInt64 = 120
//    static let hzInterval        : Double = 1.0/Double(hz)
//    static let nanoSleep         : UInt64 = UInt64(hzInterval * Double(NSEC_PER_SEC))
    // TODO: Consider putting the interval in a UserDefault.

    static let secondsInBuffer   : UInt64 = 2
    static let minBufferCapacity : UInt64 = secondsInBuffer * CountdownConstants.hz * 2
}

// FIXME: Figure out how to collect for a new subject.
//        That is, you may not be killing this app before a second subject arrives to take a new test. The loop-exhaustion process forecloses a restart in-place.
//  Can you replace `.shared`?


// MARK: - Available / Active
/// Wrapper for the availability and activity of some facility.
protocol Availability {
    var available: Bool { get }
    var active   : Bool { get }
}

/// Availability (has any Core Motion and active status for the device
struct DeviceState: Availability {
    private var cmManager: CMMotionManager

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
    private var cmManager: CMMotionManager
    init(_ manager: CMMotionManager) {
        self.cmManager = manager
    }

    /// Whether the device is capable of accelerometry
    var available: Bool {
        cmManager.isAccelerometerAvailable
        }
    /// Whether the device is recording accelerometry.
    var active   : Bool  {
        cmManager.isAccelerometerActive
        }
}

// MARK: - Top-level queue status
/// The run status of a ``MotionManager``: Running, halted, illegal, or error
enum Lifecycle: Equatable {
    case idle, running, error(Error), broken
    static func == (lhs: Lifecycle, rhs: Lifecycle) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
            (.running, .running),
            (.broken, .broken)
            : return true
        case (.error, .error): return true
        default:
            return false
        }
    }
}

// MARK: - MotionManager
/// Wrapper around `CMMotionManager` with convenient start / stop / `AsyncSequence` for accelerometry,
final class MotionManager: ObservableObject {
    /// Access to the singleton ``MotionManager``.
    ///
    /// - bug: A single instance can't be restarted for a new walk. Add a way to replace `Self.shared`.

    // MARK: Properties
    /// The active-walk phase for which `self` collects data. Used to pre-fill data identifiers on CSV records and file names.
    var walkingState: WalkingState = .walk_1
//    var walkingState: WalkingState? = nil
    /// Reset status and accelerometer queue to as-new condition
    /// - parameter newPhase: the walk `WalkingState` identifying the next walking task the object is to serve.
    /// - returns: An array of the `CMAccelerometerData` that had been in the queue. Can be ignored.
    @discardableResult
    func reset(newPhase: WalkingState) async -> [CMAccelerometerData] {
        // warning: The result is discardable.
        // You should have harvested the data result already.
        let retval = await asyncBuffer.popAll()
        walkingState = newPhase
        return retval
    }



    static var census = 0

    var lastTimeStamp: TimeInterval = -TimeInterval.infinity

    let cmMotionManager: CMMotionManager
    private let deviceState : DeviceState
    private let accState: AccelerometerState

    typealias CMDataStream = AsyncStream<CMAccelerometerData>
    var asyncBuffer: IncomingAccelerometry

    // MARK: - Initialization and start
    init(phase: SeriesTag) {
        // temp to avoid configuration through self
        let cmManager = CMMotionManager()
        cmManager.accelerometerUpdateInterval = CountdownConstants.hzInterval
        cmMotionManager = cmManager

        deviceState = DeviceState(cmManager)
        accState = AccelerometerState(cmManager)
        asyncBuffer = IncomingAccelerometry(phase: phase)
    }

    var accelerometryAvailable: Bool {
        accState.available
    }

    var accelerometryActive: Bool {
        accState.active
    }

    @Published var lifecycle = Lifecycle.idle

    static let opsQueue: OperationQueue = {
        let retval = OperationQueue()
        retval.qualityOfService = .userInitiated
        // Actually, are we cool with letting OQ spawn
        // as many threads as it wants?
        retval.maxConcurrentOperationCount = 1
        return retval
    }()

    func start() {
        cmMotionManager.startAccelerometerUpdates(to: Self.opsQueue, withHandler: accelerometryHandler)
        lifecycle = .running
    }

    private func accelerometryHandler(newElement: CMAccelerometerData?,
                                      error: Error?)
    {
        guard lifecycle == .running else { return }
        if let error { lifecycle = .error(error) }
        guard let newElement else {
            lifecycle = .broken
            return
        }
        Task {
            await self.asyncBuffer.receive(newElement)
        }
    }

    func halt() {
        cmMotionManager.stopAccelerometerUpdates()
        lifecycle = .idle
    }
}
