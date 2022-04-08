//
//  ContentView.swift
//  Async Accel
//
//  Created by Fritz Anderson on 3/10/22.
//

import SwiftUI
import CoreMotion

struct ContentView: View {
    enum Errors: Error {
        case collectionCancelled
    }

    // MARK: State
    /// Flag indicating that the user has started collecting accelerometry at all.
    static var hasCollected = false
    /// The truth of whether data collection is permitted and in progress.
    @State private var isCollecting = false {
        didSet {
            if !isCollecting && oldValue  {
                Self.hasCollected = true
            }
        }
    }
    @EnvironmentObject var crappySubjectID: SubjectID

    private var motionManager = MotionManager()
    /// The most-recently-reported xyz acceleration vector.
    ///
    /// ATW the value is set from the data loop as a moving average:
    /// Review the `smoothing~` vars.
    @State var reading: CMAcceleration = CMAcceleration()

    // MARK: smoothed data
    static let smoothingCount = 10
    @State private var smoothingWindow = Array(repeating: CMAcceleration(), count: Self.smoothingCount)
    @State private var smoothingIndex = 0



    // MARK: - body
    var body: some View { NavigationView() {
        VStack(alignment: .center, spacing: 20.0) {
            Spacer()
            HStack {
                // Debug-only. Show whether collection is available,
                // and label a button for stopping or starting collection
                Text(labels.status)
                Spacer()
                Button(labels.button) {
                    isCollecting.toggle()
                }
                .disabled(labels.button.isEmpty)
            }
            .padding()

            // Debug-only. Verify that the subject ID is correct.
            Text("id: ").fontWeight(.semibold)
            + Text(
                //                SubjectID.shared
                crappySubjectID.subjectID ?? "N/A"
            )

            // MARK: Data display
            if isCollecting {
                GeometryReader { proxy in
                    VStack {
                        verticalBars( ofHeight: proxy.size.height)
                        horizontalBar(ofHeight: proxy.size.height)
                    }
                }
            }
            Spacer()
        }
        .navigationTitle("Accelerometry")
        .padding()
        .task {
            await startDataLoop()
        }
    }
    }

    // MARK: - Data collection

    /// Start an asynchronous  accelerometry loop that consumes observations and passes a moving average to the `View`.
    ///
    fileprivate func startDataLoop() async {
        do {
            for try await datum in motionManager {
                defer {
                    smoothingIndex = (smoothingIndex + 1) % Self.smoothingCount
                }
                // push the new value into the buffer
                smoothingWindow[smoothingIndex] = datum.acceleration
                // average the buffer
                let average = smoothingWindow
                    .reduce(.zero, +) / Self.smoothingCount
                // pass the average to the UI.
                reading = average
            }
        }
        catch {
            // Kill data-gathering upon error (not exhaustion).
            motionManager.cancelUpdates()
        }
    }

    // MARK: Subview helpers
    /// Wrapper to construct a bar graph with the `log` of the magnitude of the `x`, `y`, and `z` vector.
    /// - Parameter height: The max-value height of the view
    /// - Returns: A vertical-bar view depicting the 3-axis data.
    fileprivate func verticalBars(ofHeight height: CGFloat) -> some View {
        return SimpleBarView(
            [
                abs(reading.x),
                abs(reading.y),
                abs(reading.z)
            ],
            spacing: 0.20, color: .blue, reservedMax: 1.25)
        .frame(height: 0.90 * height)
    }

    /// Wrapper to construct a single-axis bar view (G-force in this application) on a `log` scale.
    /// - Parameter height: The vertical space allotted to the bar view.
    /// - Returns: A `SimpleHBarView` that can display the current `reading`.
    fileprivate func horizontalBar(ofHeight height: CGFloat) -> some View {
        return SimpleHBarView(gRange: 0.5...1.25,
                              datum: reading)
        .frame(height: 0.1 * height)
    }

    /// The `String`s for induicating availability (in a `Text`) and a label for the start/stop button.
    /// - returns: The status and button-label strings as a pair.
    var labels: (status: String, button: String) {
        if !motionManager.accelerometryAvailable {
            return (status: "Accelerometry is unavailable.", button: "")
        }
        else if isCollecting  {
            return (status: reading.description, button: "Stop")
        }
        else {
            return (status: "Idle", button: "Start")
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SubjectID.shared)
    }
}
