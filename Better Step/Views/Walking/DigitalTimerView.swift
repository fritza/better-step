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
 - ``controller``
 - ``body``
 */

/*
 How do we work the MotionManager iterator?
 Should DigitalTimerView bother accepting data at all?
 Put that in a "manager?"

 In time, it should not be responsible for cancellation. Except… we do that already for TimeReader
 */

struct DigitalTimerView: View {
    static var dtvSerial = 100
    let serialNumber: Int

    @ObservedObject var timer: TimeReader
    @State private var minSecfrac: MinSecAndFraction?

    var walkingState: WalkingState

    private let expirationCallback: (() -> Void)?

    var observer = TimedWalkObserver(title: "some Timer")

    init(duration: TimeInterval,
         walkingState: WalkingState,
         immediately completion: (() -> Void)? = nil,

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

//        print("DigitalTimerView.init", serialNumber,
//              "called from", function, "\(fileID):\(line)")

        let tr =  TimeReader(interval: duration)
        self.timer = tr
        expirationCallback = completion
    }

    fileprivate func timerStateDidChange(_ stat: TimeReader.TimerStatus) {
        if stat == .expired {
            expirationCallback?()
        }
        else if stat == .running {
        }

        // If the timer halts, stop collecting.
        switch timer.status {
        case .cancelled, .expired:
            observer.stop()
            // Now that it's stopped, you're ready to write a CSV file
            // Do not call reset or clearRecords, you need those for writing.

        default: break
        }
    }

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
            await self.observer.start()
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
                try observer
                    .writeForArchive(tag: self.walkingState.csvPrefix!)
//                try observer
//                    .writeToFile(walkState: self.walkingState)
            } catch {
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
            DigitalTimerView(duration: CountdownConstants.countdownDuration,
                             walkingState: .walk_2)
                .padding()
        }
    }
}
