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

@available(*, unavailable,
            message: "Do not use, no replacement")
struct SpeechOnOffView: View {
    // Don't use AppStorage for this,
    // it obscures the dependency up through DigitalTimerView..
    let text: String?
    @Binding var speechValue: Bool
    let size: CGSize

    init(toggling: Binding<Bool>, size: CGSize, label: String? = nil) {
        self.text = label
        self._speechValue = toggling
        self.size = size
    }

    var body: some View {
        HStack(alignment: .center) {
            if let text {
                Text("\(text)")
                    .minimumScaleFactor(0.5)
                Spacer(); Divider()
            }
            Spacer()
            Toggle("Speech", isOn: $speechValue)
                .frame(width: size.width * 0.4)
        }.frame(height: 50)
    }
}

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
#if RETAIN_VOICE
            playSound(named: "Klaxon",
                      thenSay: "Stop walking.")
#endif
            expirationCallback?()
        }
        else if stat == .running {
#if RETAIN_VOICE
            let content = (walkingState == .walk_1) ?
            "Start walking." : "Start your fast walk."
            playSound(named: "Klaxon",
                      thenSay: content)
#endif
        }

        // If the timer halts, stop collecting.
        switch timer.status {
        case .cancelled, .expired: observer.stop()
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
            timer.start()
        }
        .onDisappear() {
            do {
                try observer
                    .writeForArchive(tag: self.walkingState.csvPrefix!)
//                try observer
//                    .writeToFile(walkState: self.walkingState)
            } catch {
                print("DigitalTimerView:\(#line) error on write: \(error)")
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
#if RETAIN_VOICE
            CallbackUtterance(
                string: newTime.spoken)
            .speak()
#endif
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
