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
//final class
actor
IncomingAccelerometry {
    var buffer = Deque<CMAccelerometerData>(
        minimumCapacity: numericCast(CMTimeInterval.minBufferCapacity))
    var count: Int {
        buffer.count
    }

    func receive(_ accData: CMAccelerometerData) {
        buffer.append(accData)
    }

    // FIXME: - Does pop() deadlock receive(_:)?
    //      It spins waiting for the arrival of data into the buffer.
    //      If the suspension point at Task.sleep(nanoseconds:) doesn't
    //      yield to an async receive(_:), then we're deadlocked, right?
    func pop() async throws -> CMAccelerometerData? {
        while buffer.isEmpty {
            try Task.checkCancellation()
            try await Task.sleep(nanoseconds: CMTimeInterval.nanoSleep)
        }
        return buffer.popFirst()
    }
    // And now we're back to polling, right?
}
