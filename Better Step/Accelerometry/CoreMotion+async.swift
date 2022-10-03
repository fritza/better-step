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


        // TODO: What ops queue should this go on?
        //       You create a new one by instantiating with `init()`.
        //       I'd want serial. I don't need the main actor.
        //       Should I go nuts with a separate queue for writing the
        //       results? Probably not. Let the other things do what
        //       they do without forcing a queueing system on top of
        //       whatever the Task chooses.

        motionManager.startAccelerometerUpdates(to: .main)
        { accData, error in
            if let error {
                print(#function, "Accelerometry error:", error)
                self.cancelUpdates()
            }
            if let accData {
                Task {
                    // Task? Really?
                    await self.asyncBuffer.receive(accData)
                    Self.census = await self.asyncBuffer.count
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
}


