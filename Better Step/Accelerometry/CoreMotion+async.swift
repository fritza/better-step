//
//  CoreMotion+async.swift
//  Better Step
//
//  Created by Fritz Anderson on 10/3/22.
//

import Foundation
import CoreMotion


extension MotionManager: AsyncSequence, AsyncIteratorProtocol {
    // MARK: - AsyncSequence
    typealias Element = CMAccelerometerData
    typealias AsyncIterator = MotionManager
    
    func next() async throws -> CMAccelerometerData? {
        while let accData = motionManager.accelerometerData,
              accData.timestamp == lastTimeStamp {
            try Task.checkCancellation()
            try await Task.sleep(nanoseconds: CMTimeInterval.nanoSleep/4)
        }
        // By here
        // EITHER there is no data (probably the cm manager hasn't started or has stopped)
        // OR     there is a new timestamp.
        // Either way, report the data/absence
        return motionManager.accelerometerData
    }

    func makeAsyncIterator() -> MotionManager {
        motionManager.startAccelerometerUpdates()
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

    /// Halt Core Motion reports on accelerometry.
    ///
    /// Not intended for external use; use `.cancelUpdates()` instead.
    private func stopAccelerometer() {
        motionManager.stopAccelerometerUpdates()
    }
}


