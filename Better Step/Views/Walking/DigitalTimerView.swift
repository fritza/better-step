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

struct DigitalTimerView: View, ReportingPhase {
    static let timeKeeperSpec = Timekeeper.TimingSpec(
        duration: CountdownConstants.walkDuration,
        increment: CountdownConstants.timerTick,
        tolerance: CountdownConstants.timerTolerance,
        roundingScale: CountdownConstants.secondsRoundingFactor,
        units: [.mmSecondsString]
        )

//    @EnvironmentObject var resetState: ResetStatus

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
        self.motionManager = MotionManager(phase: walkingState)
        self.walkingState = walkingState
        self.completion = completion
    }

    // FIXME: Test this.
    fileprivate func timerStateDidChange(_ stat: Timekeeper.Status) {
        switch stat {
        case .cancelled      : completion(.failure(AppPhaseErrors.walkingPhaseProbablyKilled(self.walkingState)))
        case .completed      : completion(.success(self.motionManager.asyncBuffer))
        default: break
        }
}
        /*
        if stat == .expired {
//            ANYTHING
        }
        else if stat == .running {
        }

        // If the timer halts, stop collecting.
        switch timer.status {
        case .cancelled, .expired:
            motionManager.halt()
            // Now that it's stopped, you're ready to write a CSV file
            // Do not call reset or clearRecords, you need those for writing.

        default: break
        }
    }
         */

    var body: some View {
        GeometryReader { proxy in
            VStack {
                // Instructions
                Text(digitalNarrative)
                    .foregroundColor(.red)
                Spacer()
                // MM:SS to screen
                Text(timer.minuteSecondString)
//                Text(minSecString ?? "xx:xx")
                    .font(.system(size: 100, weight: .ultraLight))
                    .minimumScaleFactor(0.5)
                    .monospacedDigit()

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
            await self.motionManager.reset(newPhase: self.walkingState)

            self.motionManager.start()
            // This appends CMAccelerometerData to
            // the observer's consumer list.
        }
        .onAppear {
            do {
// if !DEBUG
                try MorseHaptic.aaa?.play()
// endif
            }
            catch {
// if DEBUG
                print(#function, "line", #line, "can't play the haptic:", error.localizedDescription)
// endif
            }
            timer.start()
        }
        .onDisappear() {
            do {
// if !DEBUG
                try MorseHaptic.nnn?.play()
// endif
                Task {
                    //                    let allData = await motionManager.asyncBuffer.allAsTaggedData()
                    completion(.success(motionManager.asyncBuffer))
                }
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

//    func start() {
//        timer.start()
//    }
}

// MARK: - Preview
struct DigitalTimerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DigitalTimerView(duration: CountdownConstants.walkDuration,
                             walkingState: .walk_2) {
                result in
                switch result {
                case .success:
                    print("DTV succeeded.")
                case .failure(let err):
                    print("DTV failed:", err)
                }
            }
                .padding()
                .environmentObject(MotionManager(phase: .walk_1))
                .environmentObject(ResetStatus())
        }
    }
}
