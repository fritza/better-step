//
//  CoreMotion.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/14/22.
//

import Foundation
import CoreMotion

protocol Availability {
    var cmManager: CMMotionManager { get }
    var availPath: KeyPath<CMMotionManager, Bool> { get }
    var activePath: KeyPath<CMMotionManager, Bool> { get }
}

extension Availability {
    var active   : Bool  { cmManager[keyPath: activePath] }
    var available: Bool  { cmManager[keyPath: availPath ] }
}

struct DeviceState: Availability {
    private(set) var availPath: KeyPath<CMMotionManager, Bool> = \.isDeviceMotionAvailable
    private(set) var activePath: KeyPath<CMMotionManager, Bool> = \.isDeviceMotionActive
    private(set) var cmManager: CMMotionManager
}

struct AccelerometerState: Availability {
    private(set) var availPath: KeyPath<CMMotionManager, Bool> = \.isAccelerometerAvailable
    private(set) var activePath: KeyPath<CMMotionManager, Bool> = \.isAccelerometerActive
    private(set) var cmManager: CMMotionManager
}



final class MotionManager {
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

    var stream: AsyncStream<AccelerometerItem>!

    private init() {
        let cmManager = CMMotionManager()
        cmManager.accelerometerUpdateInterval = 0.001
        motionManager = cmManager

        deviceState = DeviceState(cmManager: cmManager)
        accState = AccelerometerState(cmManager: cmManager)
        Self.shared = self
    }

    func startAccelerometry() {
        stream = AsyncStream {
            continuation in
            motionManager.startAccelerometerUpdates(
                to: .main, withHandler: Self.makeHandler(continuation)
                )
            continuation.onTermination = {
                @Sendable _ in
                self.motionManager.stopAccelerometerUpdates()
            }
        }
    }

}

extension MotionManager {
    static func makeHandler(
        _ closedContinuaion: AsyncStream<AccelerometerItem>.Continuation)
    // FIXME: Provide CMAccelerometerData, not AccelerometerItem
    -> (CMAccelerometerData?, Error?)->Void
    {
        return {
            (aData: CMAccelerometerData?, error: Error?) -> Void in
            if let error = error {
                print(#function, "- got unhandled error:", error)
                return
            }
            guard let aData = aData else {
                fatalError("\(#function):\(#line) - no error, but no data.")
            }
            closedContinuaion.yield(AccelerometerItem(aData))
        }
    }
}
