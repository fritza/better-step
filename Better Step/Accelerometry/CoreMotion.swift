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

    private init() {
        let cmManager = CMMotionManager()
        cmManager.accelerometerUpdateInterval = 0.001
        motionManager = cmManager

        deviceState = DeviceState(cmManager: cmManager)
        accState = AccelerometerState(cmManager: cmManager)

        Self.shared = self
    }




    // MARK: Life Cycle
    /// Start accelerometer collection
    func startAccelerometer() {
        let params = Configuration.shared.accelerometer
        accelerometryStarted = Date()

        #if !SUPPRESS_CM
        assert(motionManager != nil)
        motionManager
            .accelerometerUpdateInterval = 1.0/params.frequency

        motionManager
            .startAccelerometerUpdates(to: opQueue) {
                accData, error in
                if let error = error {
                    print(#function, "error in accelerometer data:", error)
                    return
                }
                guard let accData = accData else {
                    print(#function, "no data!")
                    return
                }
                let item = AccelerometerItem(accelerometry: accData)
                Report.current.append(accelerometry: item)
        }
        #else
        // SUPPRESS: Core Motion not available for this build
        simulatedSource = DispatchSource.makeTimerSource()
        simulatedSource?.schedule(
            wallDeadline: DispatchWallTime.now(),
            repeating: DispatchTimeInterval.milliseconds(100))

        // 10 times a second instead of 30 or 60.
        simulatedSource?.setEventHandler {
            let item = AccelerometerItem(
                timestamp: Date().timeIntervalSince(self.accelerometryStarted!),
                x: 1.0, y: 2.0, z: 3.0)
            Report.current.append(accelerometry: item)
        }
        simulatedSource?.resume()
        #endif
    }

}


