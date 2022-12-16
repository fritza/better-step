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
//    typealias Element = CMAccelerometerData
    typealias Element = XYZT
    typealias AsyncIterator = MotionManager
    
    func next() async throws -> XYZT? {
        while let accData = cmMotionManager.accelerometerData,
              accData.timestamp == lastTimeStamp {
            guard self.lifecycle == .running else { return nil }
            try await Task.sleep(nanoseconds: CountdownConstants.nanoSleep/4)
        }
        // By here
        // EITHER there is no data (probably the cm manager hasn't started or has stopped)
        // OR     there is a new timestamp.
        // Either way, report the data/absence
        return cmMotionManager.accelerometerData?.asXYZT
    }

    func makeAsyncIterator() -> MotionManager {
//        motionManager.startAccelerometerUpdates()
        return self
    }
}
