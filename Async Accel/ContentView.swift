//
//  ContentView.swift
//  Async Accel
//
//  Created by Fritz Anderson on 3/10/22.
//

import SwiftUI
import CoreMotion

extension CMAcceleration: CustomStringConvertible {
    public var description: String {
        "Acc(\(x.pointThree), \(y.pointThree), \(z.pointThree))"
    }
}

final class CMWatcher: ObservableObject {
    @Published var reading: CMAccelerometerData
    static var census: Int = 0
    private var motionManager: MotionManager

    init() {
        motionManager = MotionManager()
        reading = CMAccelerometerData()

        Task {
            do {
                for try await datum in motionManager {
                    reading = datum
                    CMWatcher.census = await motionManager.count()
                }
            }
            catch {
                motionManager.cancelUpdates()
            }
        }
    }
}

struct ContentView: View {
    static let hzOverride: TimeInterval = 1.0/4.0

    enum Errors: Error {
        case collectionCancelled
    }
    @State private var isCollecting = false
//    private var motionManager = CMWatcher()
    private var motionManager = MotionManager()
    @State var reading: CMAccelerometerData = CMAccelerometerData()
    var bufferCount: String = ""
    mutating func updateCount(_ n: Int) {
        bufferCount = String(n)
    }

    var labels: (status: String, button: String) {
        if !motionManager.accelerometryAvailable {
            return (status: "Not available", button: "")
        }
        else if isCollecting  {
            return (status: reading.acceleration.description, button: "Stop")
        }
        else {
            return (status: "Idle", button: "Start")
        }
    }

    var body: some View {
        VStack(alignment: .center, spacing: 20.0) {
            Spacer()
            Text("Async Accelerometry")
                .font(.largeTitle)
            // TODO: Show the count in the IncomingAccelerometry buffer.
            // It's impossible to isolate a var.
            // But the count varies. It reports
            // the state of the accelerometry queue,
            // which is isolated.
            HStack {
                Text(labels.status)
                Spacer()
                Button(labels.button) {
                    isCollecting.toggle()
                }
                .disabled(labels.button.isEmpty)
            }
            .padding()
            if isCollecting {
                SimpleBarView(
                    [
                        abs(reading.acceleration.x),
                        abs(reading.acceleration.y),
                        abs(reading.acceleration.z)
                    ],
                    spacing: 0.20, color: .blue, reservedMax: 1.25)
                    .animation(
                        .easeInOut(duration: Self.hzOverride),
                        value: reading.acceleration.x)
            }
            Spacer()
        }
        .padding()
        .task {
            do {
                for try await datum in motionManager {
                    reading = datum
                }
            }
            catch {
                motionManager.cancelUpdates()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
