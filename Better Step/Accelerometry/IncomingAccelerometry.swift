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
    // MARK: queue status
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

// MARK: Properties
    static let opsQueue: OperationQueue = {
        let retval = OperationQueue()
        retval.qualityOfService = .userInitiated
        // Actually, are we cool with letting OQ spawn
        // as many threads as it wants?
        retval.maxConcurrentOperationCount = 1
        return retval
    }()

    let motionManager = MotionManager()
#warning("Audit all other instantiations of MotionManager.")
    // ALSO, what are the prerequisites for instantiating one?

    var lifecycle = Lifecycle.idle

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
        let content = buffer[..<count]
        buffer.removeFirst(number)
        return Array(content)
    }

    // MARK: Accelerometry start/stop
    func proceed() {
        motionManager.motionManager.startAccelerometerUpdates(
            to: Self.opsQueue,
            withHandler: accelerometryHandler)
    }

    private func accelerometryHandler(newElement: CMAccelerometerData?,
                                      error: Error?)
    {
        guard lifecycle == .running else { return }
        // This should not be the only thing that (fails to)
        // happen upon cancellation
        if let error { lifecycle = .error(error) }
        guard let newElement else {
            lifecycle = .broken
            return
        }
        buffer.append(newElement)
    }

    func halt() {
        // Note that we're really not using MotionManager()
        // except for its peripheral setup tasks.
        lifecycle = .idle
        motionManager.motionManager.stopAccelerometerUpdates()
    }
}
