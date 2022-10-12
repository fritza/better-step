//
//  SweepSecondView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/20/22.
//

#warning("read me: completion errors")
/*
 My present concern is that the completion/cancellatioin errors don't get thrown, or are otherwise ignored; so the timer iteself never pushes up something to distinguis reasons for stopping.
 Remember: THROWING THE COMPLETION "ERRORS" CANCELS THE TIMER.
 */



import SwiftUI
import Combine

/**
 ## Topics

 ### Properties
 - ``isRunning``
 - ``body``
 */

// FIXME: Add an Error that describes cancellation.


/// A `View` that displays a circle containing a sweep-second hand and a digit, representing a countdown in seconds.
///
/// Note that the timer can't be paused, only canceled. After cancellation, the only thing to be done is to create a new timer, and assign it the full duration.
struct SweepSecondView: View, ReportingPhase {
    typealias SuccessValue = ()
    typealias ResultValue = Result<SuccessValue,Error>
    typealias SSVClosure = ((Result<(), Error>) -> Void)

    static let timeKeeperSpec = Timekeeper.TimingSpec(
        duration: CountdownConstants.sweepDuration,
        increment: CountdownConstants.timerTick,
        tolerance: CountdownConstants.timerTolerance,
        roundingScale: CountdownConstants.secondsRoundingFactor,
        units: [.seconds, .fraction]
        )

    @Environment(\.colorScheme) private static var colorScheme: ColorScheme
    @StateObject var timer: Timekeeper = Timekeeper(Self.timeKeeperSpec)

    /// The closure provided by client code at `init` to notify it of expiration
    let completion: SSVClosure!
    // TODO: This isn't what you'd use
    // if this were a ReportingPhase.

    /// Initialize `SweepSecondView` with the duration of the countdown and a completion block.
    /// - Parameters:
    ///   - duration: `TimeInterval` (in seconds to count down from
    ///   - onCompletion: Closure to notify the client that the countdown has run out.
    init(duration: TimeInterval,
         onCompletion: @escaping SSVClosure,
         function: String = #function,
         fileID: String = #file,
         line: Int = #line
    ) {
//        wholeSeconds = Int(duration)
        self.completion = onCompletion
    }

    // MARK: Subview builders
    var stringForSeconds: String {
        if (0...Int(CountdownConstants.sweepDuration))
            .contains(timer.seconds) {
            return String(timer.seconds+1)
        }
        else { return "*" }
    }

    /*
    var xxStringForSeconds: String {
        if let wholeSeconds, wholeSeconds >= 0,
           wholeSeconds <= Int(CountdownConstants.walkDuration) {
            return String(describing: wholeSeconds+1)
        }
        else { return "*" }
    }
     */

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
            SubsecondHandView(fractionalSecond: timer.fraction)
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

            // MARK: Clock status
            .onChange(of: timer.status,
                      perform:
                        { newValue in
                switch newValue {
                    // TODO: Should an error be propagating?
                    // I don't see why. The status itself
                    // says everything there is to say.
                case .cancelled:
                    completion?(
                        .failure(Timekeeper.Status.cancelled))
                case .completed:
                    completion?(.failure(Timekeeper.Status.completed))
                default: break
                }
            })
            .onAppear {
                // Delay a little bit so the view syncs to the audio
                Timer.scheduledTimer(
                    withTimeInterval: CountdownConstants.sweepSecondDelay,
                    repeats: false) { _ in
                        timer.start()
                }
                do {
                    try AudioMilestone.shared.play()
                }
                catch {
                    print(#function, ":", #line, "- attempt to play countdown audio failed:", error.localizedDescription)
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
                result in
                switch result {
                case .success:
                    print("Succeeded")
                case .failure(let error):
                    print("Failed with error", error)
                }
            }
//            .environmentObject(MotionManager(phase: .countdown_1))
//            .environmentObject(
//                Timekeeper(SweepSecondView.timeKeeperSpec)
//            )
            .frame(width: 300)
        }
    }
}
