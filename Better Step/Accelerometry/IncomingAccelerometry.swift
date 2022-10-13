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
public actor IncomingAccelerometry {

// MARK: Properties

    let phase: WalkingState
    init(phase: WalkingState) {
        self.phase = phase
    }

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
            try await Task.sleep(nanoseconds: CountdownConstants.nanoSleep)
        }
        return buffer.popFirst()
    }

    func popAll()  -> [CMAccelerometerData] {
        // This isn't async?!
        let content = all()
        buffer.removeFirst(content.count)
        return content
    }

    func all() -> [CMAccelerometerData] {
        let number = buffer.count
        let content = buffer[..<number]
        return Array(content)
    }
}
