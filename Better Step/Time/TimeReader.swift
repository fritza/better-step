//
//  TimeReader.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/5/22.
//

import Foundation
import Combine

#if LOGGER
import os.log
let logger = Logger()
let signposter = OSSignposter(subsystem: "com.wt9t.G-Bars",
                              category: .pointsOfInterest)
#endif

enum CountdownConstants {
#if DEBUG
    static let walkDuration    = 120.0             // 15.0
#else
    static let walkDuration    = 120.0
#endif

    static let countdownInterval    = 30
    static let sweepDuration        = 5.0
}


/// An `ObservableObject` that serves as a single source of truth for the time remaining in an interval, publishing minutes, seconds, and fractions in sync.
final class TimeReader: ObservableObject {
    enum TerminationErrors: Error, CustomStringConvertible {
        case cancelled
        case expired

        var description: String {
            switch self {
            case .expired  : return "the timer expired"
            case .cancelled: return "the count was cancelled"
            }
        }
    }

    enum TimerStatus: String, Hashable, CustomStringConvertible {
        case ready, running, cancelled, expired
        var description: String { self.rawValue }
    }


    // The current remaining time, as a ``MinSecAndFraction``
//    @Published var currentTime: MinSecAndFraction = .zero
    /// The ready/run/stopped/expired status of the count.
    @Published var status: TimerStatus = .ready

    internal var startingDate, endingDate: Date
    internal var totalInterval: TimeInterval
    internal let tickInterval: TimeInterval
    internal let tickTolerance: TimeInterval

    /// Broadcasts the current time remaining as rapidly as the underlying `Timer` publishes it.
    var timeSubject = PassthroughSubject<MinSecAndFraction, Never>()
    /// Broadcasts the current time remaining at the top of every minute.
    var mmssSubject = PassthroughSubject<MinSecAndFraction, Never>()
    /// Broadcasts only the number of seconds remaining
    var secondsSubject = PassthroughSubject<Int, Never>()

#if LOGGER
    var intervalState: OSSignpostIntervalState
#endif

    /// Collect the parameters that will initialize the time publisher and its subscribers when ``start()`` is called.
    /// - Parameters:
    ///   - interval: Duration: the total span of the countdown
    ///   - tickSize: Precision: the interval at which time will be emitted; default `0.01` (100 Hz).
    ///   - function: The call site
    ///   - fileID: The caller's file
    ///   - line: The caller's line number in that file.
    init(interval: TimeInterval,
         by tickSize: TimeInterval = 0.01,
         function: String = #function,
         fileID: String = #file,
         line: Int = #line) {

#if LOGGER
        let spIS = signposter.beginInterval("TimeReader init")
        intervalState = spIS
#endif
        tickInterval = tickSize
        tickTolerance = tickSize / 20.0

        let currentDate = Date()
        totalInterval = interval
        startingDate = currentDate
        endingDate = Date().addingTimeInterval(interval)
#if LOGGER
        signposter.endInterval("TimeReader init", spIS)
#endif
    }


    var sharedTimer: AnyPublisher<MinSecAndFraction, Error>!
    private var timeCancellable: AnyCancellable!
    private var mmssCancellable: AnyCancellable!
    private var secondsCancellable: AnyCancellable!

    /// Stop the timer and updates `status` to whether it was cancelled or simply ran out.
    func cancel() {
        status = (status == .running) ?
            .cancelled : .expired
        timeCancellable = nil
        mmssCancellable = nil
        secondsCancellable = nil
        sharedTimer = nil
    }

    #if DEBUG
    deinit {
        print("TimeReader disposed-of")
        print()
    }
    #endif

    func reset() {
        // I hate that
        let currentDate = Date()
        startingDate = currentDate
        endingDate = Date().addingTimeInterval(totalInterval)

    }

    /// Initiate the countdown that was set up in `init`.
    ///
    /// Sets up the Combine chains from the `Timer` to all the published interval components.
    func start(function: String = #function,
               fileID: String = #file,
               line: Int = #line) {
//        print("TimeReader.START called from", function, "\(fileID):\(line)")

        // FIXME: timer status versus expected
        // like ".ready" is getting seriously into misalignment.
        assert(status != .running,
        "attempt to restart a timer")

        reset()

        status = .running
        sharedTimer = setUpCombine().share().eraseToAnyPublisher()

        timeCancellable = mmss_ff_Cancellable()
        mmssCancellable = mmss_00_Cancellable()
        secondsCancellable = ss_Cancellable()
    }
    static let roundingScale = 100.0

}

