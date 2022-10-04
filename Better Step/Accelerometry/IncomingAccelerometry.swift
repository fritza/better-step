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
actor IncomingAccelerometry {
//    weak var motionManager: MotionManager!


// MARK: Properties

//    let motionManager = MotionManager()
#warning("Audit all other instantiations of MotionManager.")
    // ALSO, what are the prerequisites for instantiating one?


    var buffer = Deque<CMAccelerometerData>(
        minimumCapacity: numericCast(CMTimeInterval.minBufferCapacity))
    var count: Int {
        buffer.count
    }

    // MARK: Store/recall
    func receive(_ accData: CMAccelerometerData) {
        buffer.append(accData)
    }

    func pop() async throws -> CMAccelerometerData? {
        while buffer.isEmpty {
            try Task.checkCancellation()
            try await Task.sleep(nanoseconds: CMTimeInterval.nanoSleep)
        }
        return buffer.popFirst()
    }

    func popAll()  -> [CMAccelerometerData] {
        // This isn't async?!
        let number = buffer.count
        let content = buffer[..<number]
        buffer.removeFirst(number)
        return Array(content)
    }
}
