//
//  DigitalTimerView.swift
//  No EO
//
//  Created by Fritz Anderson on 7/19/22.
//

import SwiftUI

// MARK: - DigitalTimerView
private let digitalNarrative = """
“Cancel” will stop the count but not dispatch to a recovery page.
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

    static var dtvSerial = 100
    let serialNumber: Int
    
    @ObservedObject var timer = TimeReader(interval: CountdownConstants.walkDuration)
    @State private var minSecfrac: MinSecAndFraction?

    var walkingState: WalkingState

    typealias SuccessValue = IncomingAccelerometry
    typealias CompletionFunc = ((Result<SuccessValue, Error>) -> Void)
//    @MainActor
    var completion: CompletionFunc!
    // DAMMIT:
    // Stored property 'completion' within struct cannot have a global actor; this is an error in Swift 6

    @EnvironmentObject private var motionManager: MotionManager

    init(duration: TimeInterval,
         walkingState: WalkingState,
         immediately completion: CompletionFunc? = nil,

         function: String = #function,
         fileID: String = #file,
         line: Int = #line
    ) {
        assert(walkingState == .walk_1 || walkingState == .walk_2,
        "\(fileID):\(line): Unexpected walking state: \(walkingState)"
        )
        self.walkingState = walkingState
        serialNumber = Self.dtvSerial
        Self.dtvSerial += 1
        self.completion = completion
    }

    // FIXME: Test this.
    fileprivate func timerStateDidChange(_ stat: TimeReader.TimerStatus) {
        switch stat {
        case .cancelled      : completion?(.failure(FileStorageErrors.walkingPhaseProbablyKilled(self.walkingState)))
        case .expired        : completion?(.success(self.motionManager.asyncBuffer))
        case .ready, .running: break
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
                Text(minSecfrac?.clocked ?? "--:--" )
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
                try MorseHaptic.aaa.play()
                }
            catch {
                #if DEBUG
                print(#function, "line", #line, "can't play the haptic:", error.localizedDescription)
                #endif
            }
            timer.start()
        }
        .onDisappear() {
            do {
                try MorseHaptic.nnn.play()

                Task {
                    //                    let allData = await motionManager.asyncBuffer.allAsTaggedData()
                    completion?(.success(motionManager.asyncBuffer))
                }
            }
            catch {
                print("DigitalTimerView:\(#line) error on write/haptic: \(error)")
                assertionFailure()
            }
            // Is this handler really the best place?
            // or onReceive of timer.$status?
        }
        .onReceive(timer.$status, perform: { stat in
            timerStateDidChange(stat)
            // Is this handler really the best place?
            // or onDisappear?
        })
        .onReceive(timer.timeSubject, perform: { newTime in
            self.minSecfrac = newTime
        })
        .onReceive(timer.mmssSubject) { newTime in
        }
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
                             walkingState: .walk_2)
                .padding()
                .environmentObject(MotionManager(phase: .walk_1))
        }
    }
}
