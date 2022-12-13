//
//  IncomingAccelerometry.swift
//  Better Step
//
//  Created by Fritz Anderson on 10/3/22.
//

import Foundation
import CoreMotion
import Collections

// MARK: - IncomingAccelerometry


/// Async-safe deque  holding `Sequence`s of  `CMAccelerometryData`
public actor IncomingAccelerometry {

// MARK: Properties

    /// The `WalkingState` currently feeding the actor.
    ///
    /// Needed because there is no other way for storage clients to knpw which walk the data represents, and therefore how to tag it for naming and CSV.
    let phase: SeriesTag

    #warning("is .phase used?")

    /// Create an `IncomingAccelerometry` serving a particular walking task.
    /// - Parameter phase: The task (walks 1 or 2) for which the actor is collecting data.
    init(phase: SeriesTag) {
        self.phase = phase
    }

    private var buffer = Deque<CMAccelerometerData>(
        minimumCapacity: numericCast(CMTimeInterval.minBufferCapacity))
    /// How many data points have been collected but not consumed.
    var count: Int {
        buffer.count
    }

    // MARK: Store/recall
    /// Append a data point to the buffer.
    /// - Parameter accData: The data to append to the buffer.
    /// - note: `CMAccelerometerData` is the acceleration forces, _plus_ a timestamp.
    func receive(_ accData: CMAccelerometerData) {
        buffer.append(accData)
    }

    /// If a `CMAccelerometerData` is available, remove it and yield it to the caller; otherwise wait.
    /// - note: `CMAccelerometerData` is the acceleration forces, _plus_ a timestamp.
    /// - Returns: The oldest  `CMAccelerometerData` in the queue
    /// - throws: `Task` cancellation errors.
    func pop() async throws -> CMAccelerometerData? {
        while buffer.isEmpty {
            try Task.checkCancellation()
            try await Task.sleep(nanoseconds: CountdownConstants.nanoSleep)
        }
        return buffer.popFirst()
    }

    /// Remove all data in the queue and return it as an array.
    /// - note: `CMAccelerometerData` is the acceleration forces, _plus_ a timestamp.
    /// - Returns: An array of `CMAccelerometerData`
    func popAll()  -> [CMAccelerometerData] {
        // This isn't async?!
        let content = all()
        buffer.removeFirst(content.count)
        return content
    }

    /// Return all data from the queue without removing them.
    /// - returns: All `CMAccelerometerData` in the queue.
    func all() -> [CMAccelerometerData] {
        let number = buffer.count
        let content = buffer[..<number]
        return Array(content)
    }
}
