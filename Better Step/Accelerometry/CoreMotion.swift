//
//  CoreMotion.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/14/22.
//

import Foundation
import Collections
import CoreMotion

// MARK: Time intervals
private let hz                : UInt64 = 120
private let hzInterval        : Double = 1.0/Double(hz)
private let nanoSleep         : UInt64 = UInt64(hzInterval * Double(NSEC_PER_SEC))

private let secondsInBuffer   : UInt64 = 2
private let minBufferCapacity : UInt64 = secondsInBuffer * hz * 2

// FIXME: Figure out how to collect for a new subject.
//        That is, you may not be killing this app before a second subject arrives to take a new test. The loop-exhaustion process forecloses a restart in-place.
//  Can you replace `.shared`?

// MARK: - IncomingAccelerometry
actor IncomingAccelerometry {
    var buffer = Deque<CMAccelerometerData>(minimumCapacity: numericCast(minBufferCapacity))

    func receive(_ accData: CMAccelerometerData) {
        buffer.append(accData)
    }

    // FIXME: - Does pop() deadlock receive(_:)?
    //      It spins waiting for the arrival of data into the buffer.
    //      If the suspension point at Task.sleep(nanoseconds:) doesn't
    //      yield to an async receive(_:), then we're deadlocked, right?
    func pop() async throws -> CMAccelerometerData? {
        //        return  try await Task {
        while buffer.isEmpty {
            try Task.checkCancellation()
            try await Task.sleep(nanoseconds: nanoSleep)
        }
        return buffer.popFirst()
        //        }
        //        .value
    }
    // And now we're back to polling, right?
}

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
    /// Only access to the singleton `MotionManager`; `init()` is `private`.
    static let shared = MotionManager()

    let motionManager: CMMotionManager
    private let deviceState : DeviceState
    private let accState: AccelerometerState
    var isCancelled: Bool = false

    typealias CMDataStream = AsyncStream<CMAccelerometerData>
    var stream: CMDataStream!

    let asyncBuffer = IncomingAccelerometry()

// MARK: - Initialization and start
    private init() {
        let cmManager = CMMotionManager()
        cmManager.accelerometerUpdateInterval = hzInterval
        motionManager = cmManager

        deviceState = DeviceState(cmManager)
        accState = AccelerometerState(cmManager)
    }

    /*
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
*/
    /// Halt Core Motion reports on accelerometry.
    ///
    /// Not intended for external use; use `.cancelUpdates()` instead.
    private func stopAccelerometer() {
        motionManager.stopAccelerometerUpdates()
    }
}

extension MotionManager: AsyncSequence, AsyncIteratorProtocol {
    // MARK: - AsyncSequence
    typealias Element = CMAccelerometerData
    typealias AsyncIterator = MotionManager
    func next() async throws -> CMAccelerometerData? {
        guard !isCancelled else { return nil }
        return try? await asyncBuffer.pop()
    }

    func makeAsyncIterator() -> MotionManager {
        // TODO: How do we do start-updates without starting the iterator?
        //       You might want to do the two separately...?
        //       Maybe not. I mean, if you can't start without providing
        //       an action closure, then what closure do you want except to
        //       feed the sequence?
        // How does this fail? `throws` is a supertype of non-throwing,
        // and there's no imaginable way to downcast or (more important)
        // to handle the throw.

        motionManager.startAccelerometerUpdates(to: .main)

        // TODO: What ops queue should this go on?
        //       You create a new one by instantiating with `init()`.
        //       I'd want serial. I don't need the main actor.
        //       Should I go nuts with a separate queue for writing the
        //       results? Probably not. Let the other things do what
        //       they do without forcing a queueing system on top of
        //       whatever the Task chooses.

        { accData, error in
            if let error = error {
                print(#function, "Accelerometry error:", error)
                self.cancelUpdates()
            }
            if let accData = accData {
                Task {
                    // Task? Really?
                    await self.asyncBuffer.receive(accData)
                }
            }
        }

        return self
    }

// MARK: - MotionManager life cycle

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
