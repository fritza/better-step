//
//  ContentView.swift
//  Async Accel
//
//  Created by Fritz Anderson on 3/10/22.
//

import SwiftUI
import CoreMotion

struct ContentView: View {
    static let hzOverride: TimeInterval = 1.0/4.0

    enum Errors: Error {
        case collectionCancelled
    }
    @State private var isCollecting = false
//    private var motionManager = CMWatcher()
    private var motionManager = MotionManager()
//    @State var reading: CMAccelerometerData = CMAccelerometerData()
    @State var reading: CMAcceleration = CMAcceleration()
    var bufferCount: String = ""
    mutating func updateCount(_ n: Int) {
        bufferCount = String(n)
    }

    var labels: (status: String, button: String) {
        if !motionManager.accelerometryAvailable {
            return (status: "Not available", button: "")
        }
        else if isCollecting  {
            return (status: reading.description, button: "Stop")
        }
        else {
            return (status: "Idle", button: "Start")
        }
    }

    @State var index = 0
    @State var window = Array(repeating: CMAcceleration(), count: 10)

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
                GeometryReader { proxy in
                    VStack {
                        SimpleBarView(
                            [
                                abs(reading.x),
                                abs(reading.y),
                                abs(reading.z)
                            ],
                            spacing: 0.20, color: .blue, reservedMax: 1.25)
//                        .animation(
//                            .easeInOut(duration: 4*Self.hzOverride),
//                            value: reading.x)
                        .frame(height: 0.90 * proxy.size.height)
                        SimpleHBarView(gRange: 0.5...1.25,
                                       datum: reading)
                        .frame(height: 0.1 * proxy.size.height)
                    }
                    }
            }
            Spacer()
        }
        .padding()
        .task {
            do {
                for try await datum in motionManager {
                    defer { index = (index + 1) % window.count }
                    window[index] = datum.acceleration
                    let average = window
                        .reduce(.zero, +) / window.count
                    reading = average
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
