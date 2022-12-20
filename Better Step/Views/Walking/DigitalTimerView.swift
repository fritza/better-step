//
//  DigitalTimerView.swift
//  No EO
//
//  Created by Fritz Anderson on 7/19/22.
//

import SwiftUI

// MARK: - DigitalTimerView
private let digitalNarrative = """
“Cancel” will stop the count, and ought to bounce to the introduction to walking, but this has not been rigorously tested.
"""

// FIXME: Add an Error that describes cancellation.

/**
 ## Topics

 ### Properties
 - ``text``
 -  ``size``

 ### Initializer
 - ``init(toggling:size:label:)``
 */

/**
 ## Topics

 ### Properties
 - ``body``
 */

/// Displays a coundown clock in the form `mm:ss`. Initializes, starts, and observes both ``MotionManager`` and ``Timekeeper``.
///
/// The ``SuccessValue`` as a ``ReportingPhase`` is ``IncomingAccelerometry``.
struct DigitalTimerView: View, ReportingPhase {
    static let timeKeeperSpec = Timekeeper.TimingSpec(
        duration: CountdownConstants.walkDuration,
        increment: CountdownConstants.timerTick,
        tolerance: CountdownConstants.timerTolerance,
        roundingScale: CountdownConstants.secondsRoundingFactor,
        units: [.mmSecondsString]
        )

    @StateObject private var timer = Timekeeper(Self.timeKeeperSpec)
    @State private var minSecString: String?

    @State private var showReversionAlert = false

    var walkingState: WalkingState

    typealias SuccessValue = IncomingAccelerometry
    let completion: ClosureType
    // DAMMIT:
    // Stored property 'completion' within struct cannot have a global actor; this is an error in Swift 6

    private var motionManager: MotionManager

    init(duration: TimeInterval,
         walkingState: WalkingState,
         immediately completion: @escaping ClosureType,

         function: String = #function,
         fileID: String = #file,
         line: Int = #line
    ) {
        assert(walkingState == .walk_1 || walkingState == .walk_2,
        "\(fileID):\(line): Unexpected walking state: \(walkingState)"
        )
        self.motionManager = MotionManager()
        self.walkingState = walkingState
        self.completion = completion
    }

    /// Respond to timer-ended events by posting `success`/`failure` through `completion()`, and setting `isIdleTimerDisabled` to `false`.
    fileprivate func timerStateDidChange(_ stat: Timekeeper.Status) {
        #if DEBUG
        completion(.success(self.motionManager.asyncBuffer))
        #else
        switch stat {
        case .cancelled      :
            completion(
                .failure(
                    AppPhaseErrors
                        .walkingPhaseProbablyKilled(
                            self.walkingState.seriesTag!))
            )

        case .completed      :
            completion(.success(self.motionManager.asyncBuffer))
        default: break
        }
        #endif
    }

    var body: some View {
        GeometryReader { proxy in
            VStack {
                // Instructions
                Spacer()

                // MM:SS to screen
                HStack {
                    Spacer()
                    Text(timer.minuteSecondString)
                        .font(.system(size: 120, weight: .ultraLight))
                        .minimumScaleFactor(0.5)
                        .monospacedDigit()
                        .frame(minWidth: 220, idealWidth: 260, maxWidth: 400)
                    Spacer()
                }
                // Start/stop
                Spacer()
                Button("Cancel") {
                    timer.cancel()
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ReversionButton(toBeSet: $showReversionAlert)
            }
        }
        .reversionAlert(on: $showReversionAlert)
        .task {
            // warning: The result is discardable.
            // You should have harvested the data result already.
            await self.motionManager.reset()

            self.motionManager.start()
            // This appends CMAccelerometerData to
            // the observer's consumer list.
        }
        .onAppear {
            do {
                try MorseHaptic.aaa?.play()
            }
            catch {
                print(#function, "line", #line, "can't play the haptic:", error.localizedDescription)
            }
            timer.start()
        }
        .onDisappear() {
            do {
                try MorseHaptic.nnn?.play()
            }
            catch {
                print("DigitalTimerView:\(#line) error on write/haptic: \(error)")
                assertionFailure()
            }
            // Is this handler really the best place?
            // or onReceive of timer.$status?
        }
        .onChange(of: timer.status, perform: { stat in
            // FIXME: Why call into timerStateDidChange?
            timerStateDidChange(stat)
            // Is this handler really the best place?
            // or onDisappear?
        })
        .navigationTitle(
            (walkingState == .walk_1) ?
            "Normal Walk" : "Fast Walk"
        )
    }
}

// MARK: - Preview
struct DigitalTimerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DigitalTimerView(duration: CountdownConstants.walkDuration,
                             walkingState: .walk_1) {
                result in
                switch result {
                case .success:
                    print("DTV succeeded.")
                case .failure(let err):
                    print("DTV failed:", err)
                }
            }
                .padding()
                .environmentObject(MotionManager())
        }
    }
}
