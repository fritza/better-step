//
//  CoreMotion.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/14/22.
//

import Foundation
import CoreMotion

// FIXME: Figure out how to collect for a new subject.
//        That is, you may not be killing this app before a second subject arrives to take a new test. The loop-exhaustion process forecloses a restart in-place.
//  Can you replace `.shared`?

// FIXME: "Availability" is too cute.
protocol Availability {
    var cmManager: CMMotionManager { get }
    var availPath: KeyPath<CMMotionManager, Bool> { get }
    var activePath: KeyPath<CMMotionManager, Bool> { get }
}

extension Availability {
    var active   : Bool  { cmManager[keyPath: activePath] }
    var available: Bool  { cmManager[keyPath: availPath ] }
}

// FIXME: "Availability" is too cute.
/// Mapping of `CMMotionManager` device-motion status to `MotionManager`.
struct DeviceState: Availability {
    private(set) var availPath: KeyPath<CMMotionManager, Bool> = \.isDeviceMotionAvailable
    private(set) var activePath: KeyPath<CMMotionManager, Bool> = \.isDeviceMotionActive
    private(set) var cmManager: CMMotionManager
}

// FIXME: "Availability" is too cute.
/// Mapping of `CMMotionManager` accelerometry status to `MotionManager`.
struct AccelerometerState: Availability {
    private(set) var availPath: KeyPath<CMMotionManager, Bool> = \.isAccelerometerAvailable
    private(set) var activePath: KeyPath<CMMotionManager, Bool> = \.isAccelerometerActive
    private(set) var cmManager: CMMotionManager
}



final class MotionManager {
    /// Access to the singleton `MotionManager`.
    ///
    /// - bug: A single instance can't be restarted for a new walk. Add a way to replace `Self.shared`.
    static private(set) var shared: MotionManager! = {
        MotionManager()
    }()

    let motionManager: CMMotionManager

    private let deviceState : DeviceState
    var deviceAvailable : Bool { deviceState.available }
    var deviceActive    : Bool { deviceState.active    }

    private let accState    : AccelerometerState
    var accAvailable    : Bool { accState   .available }
    var accActive       : Bool { accState   .active    }

    typealias CMDataStream = AsyncStream<CMAccelerometerData>
    var stream: CMDataStream!

    private init() {
        let cmManager = CMMotionManager()
        cmManager.accelerometerUpdateInterval = 0.001
        motionManager = cmManager

        deviceState = DeviceState(cmManager: cmManager)
        accState = AccelerometerState(cmManager: cmManager)
        Self.shared = self
    }

    /// Commence the Core Motion feed of accelerometer events.
    ///
    /// Events are handled by creating an `AsyncStream`  around `startAccelerometerUpdates`.
    func startAccelerometry() {
        stream = AsyncStream {
            continuation in
            motionManager.startAccelerometerUpdates(
                to: .main, withHandler: Self.makeHandler(continuation)
                )
            continuation.onTermination = {
                @Sendable _ in
                self.stopAccelerometer()
            }
            // TODO: Obviates stopAccelerometer in cancelUpdates?
            // At least be on the lookout in case repeated stop calls cause problems.
        }
    }

    /// Halt Core Motion reports on accelerometry.
    ///
    /// Not intended for external use; use `.cancelUpdates()` instead.
    private func stopAccelerometer() {
        motionManager.stopAccelerometerUpdates()
    }

    var isCancelled: Bool = false
}

extension MotionManager {
    /// Halt the `CMAccelerometerData` stream by signaling the loop that it has been canceled.
    ///
    /// Use this instead of `.stopAccelerometer()` to terminate the stream. This function does call `.stopAccelerometer()`, but maybe shouldn't — see **Note**.
    ///
    /// - note: The call to `stopAccelerometer()` may be redundant of the `.onTermination` action in `startAccelerometry()`
    func cancelUpdates() {
        isCancelled = true
        stopAccelerometer()
    }

    /// Convenience: a closure that satisfies `CMAccelerometerHandler`, to handle incoming accelerometry events.
    ///
    /// The usual examples put the closure right in the call to `.startAccelerometerUpdates`, but this is more readable at that site.
    static func makeHandler(
        _ continuation: CMDataStream.Continuation)
    -> CMAccelerometerHandler
    // (CMAccelerometerData?, Error?)->Void
    {
        return {
            (aData: CMAccelerometerData?, error: Error?) -> Void in
            guard !Self.shared.isCancelled else {
                continuation.finish(); return
            }

            if let error = error {
                print(#function, "- got unhandled error:", error)
                return
            }
            guard let aData = aData else {
                fatalError("\(#function):\(#line) - no error, but no data.")
            }
            continuation.yield(aData)
        }
    }
}
