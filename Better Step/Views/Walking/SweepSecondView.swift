//
//  SweepSecondView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/20/22.
//

import SwiftUI

/**
 ## Topics

 ### Properties
 - ``isRunning``
 - ``body``
 */


/// A `View` that displays a circle containing a sweep-second hand and a digit, representing a countdown in seconds.
///
/// Note that the timer can't be paused, only canceled. After cancellation, the only thing to be done is to create a new timer, and assign it the full duration.
struct SweepSecondView: View {
    @Environment(\.colorScheme) private static var colorScheme: ColorScheme
    @ObservedObject var timer: TimeReader
    /// The current minute/second/fraction value of the countdown.
    @State private  var minSecFrac: MinSecAndFraction?
    @State private  var wholeSeconds: Int

    static let startDelay: TimeInterval = 1.2

    /// The closure provided by client code at `init` to notify it of expiration
    private let completionCallback: (() -> Void)

    /// Initialize `SweepSecondView` with the duration of the countdown and a completion block.
    /// - Parameters:
    ///   - duration: `TimeInterval` (in seconds to count down from
    ///   - onCompletion: Closure to notify the client that the countdown has run out.
    init(duration: TimeInterval,
         onCompletion: @escaping (()->Void),
         function: String = #function,
         fileID: String = #file,
         line: Int = #line
    ) {
        timer = TimeReader(interval: CountdownConstants.sweepDuration, by: 0.075)
        wholeSeconds = Int(duration)
        completionCallback = onCompletion
    }

    /// Formatted seconds from current `minSecFrac`(mm:ss.fff`).
    var stringForSeconds: String {
        if let seconds = self.minSecFrac?.second, seconds >= 0 {
            return String(describing: seconds+1)
        }
        else { return "*" }
    }

    /// A digit to be overlaid on the clock face, intended to indicate seconds remaining.
    @ViewBuilder private func numericOverlay(edge: CGFloat) -> some View {
        Text(stringForSeconds)
            .font(.system(size: edge, weight: .semibold))
            .monospacedDigit()
            .foregroundColor(.gray)
    }

    @ViewBuilder private func clockFace(fitting size: CGSize) -> some View {
        ZStack(alignment: .center) {
            Circle()
                .stroke(lineWidth: 1.0)
                .foregroundColor(.gray)

            SubsecondHandView(fractionalSecond: minSecFrac?.fraction ?? 0.0)
                .foregroundColor((Self.colorScheme == .light) ? .black : .gray)

            numericOverlay(
                edge: size.short * 0.6
            )
        }
    }

    var body: some View {
        GeometryReader { proxy in
            VStack {
                clockFace(fitting: proxy.size)
                    .frame(width:  proxy.size.short * 0.95,
                           height: proxy.size.short * 0.95,
                           alignment: .center)
                Spacer()
                Text("""
Remember to UNMUTE YOUR PHONE and turn up the audio!
""")
                .font(.callout)
                .minimumScaleFactor(0.5)
//                Spacer()
//                TimerStartStopButton(
//                    label: (isRunning) ? "Reset" : "Start",
//                    running: $isRunning)
            }
            .padding()

            // MARK: Change isRunning
            .onChange(of: timer.status, perform:
                        { newValue in
                switch newValue {
                case .cancelled, .expired:
                    // Timer's already completed, hence status
                    completionCallback()
                default: break
                }
            })

            // MARK: Time subscription -> sweep second
            // Change of mm:ss.fff - sweep angle
            .onReceive(timer.timeSubject) { mmssff in
                self.minSecFrac = mmssff
            }

            // MARK: Seconds -> Overlay + speech
            // Change of :ss. (speak seconds)
            .onReceive(timer.secondsSubject) {
                secs in
                self.wholeSeconds = secs
            }

            .onAppear() {
                Timer.scheduledTimer(
                    withTimeInterval: Self.startDelay,
                    repeats: false) { _ in
                        timer.start()
                }

                do {
                    try AudioMilestone.shared.play()
                }
                catch {
#if DEBUG
                    print(#function, ":", #line, "- attempt to play countdown audio failed:", error.localizedDescription)
#endif
                }
            }
            .navigationTitle("Start in…")
        }
    }
}

struct SweepSecondView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SweepSecondView(duration: CountdownConstants.sweepDuration) {
                
            }
            .frame(width: 300)
        }
    }
}
