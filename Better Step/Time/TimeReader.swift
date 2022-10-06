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

    private var startingDate, endingDate: Date
    private let totalInterval: TimeInterval
    private let tickInterval: TimeInterval
    private let tickTolerance: TimeInterval

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


    private var sharedTimer: AnyPublisher<MinSecAndFraction, Error>!
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

        startingDate = Date()
        endingDate = Date().addingTimeInterval(totalInterval)
        status = .running
        sharedTimer = setUpCombine().share().eraseToAnyPublisher()

        timeCancellable = sharedTimer
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    guard let err = error as? TerminationErrors else {
//                        print("Timer serial", self.serial, ": other error: \(error).")
                        return
                    }
                    switch err {
                    case .expired:
                        self.status = .expired
                        //print("Timer serial", self.serial, "ran out")
                    case .cancelled:       // print("Timer serial", self.serial, "was cancelled")
                        self.status = .cancelled
                    }
                }
            } receiveValue: { msf in
                self.timeSubject.send(msf)
            }

        mmssCancellable = sharedTimer
            .map { time in
                return time.with(fraction: 0.0)
            }
            .replaceError(with: .zero)
            .filter {
                $0.second % CountdownConstants.countdownInterval
                 == 0
            }
            .removeDuplicates()
            .sink { mmssfff in
                self.mmssSubject.send(mmssfff)
            }

        secondsCancellable = sharedTimer
            .map { $0.second }
            .filter { $0 >= 0 }
            .removeDuplicates()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        if let error = error as? TerminationErrors {
                            if error == .expired {
                                self.status = .expired
                            }
                            else {
                                self.status = .cancelled
                            }
                        }
                    }
                }, receiveValue: {
                    secInteger in
                    self.secondsSubject.send(secInteger)
                }
            )
//        print("Timer serial", serial, "was started.")
    }

    static let roundingScale = 100.0

    /// A `Publisher` that emits the `Timer`'s `Date` as minute/second/fraction at every tick.
    /// - Returns: The `Publisher` resulting from that chain.
    private func setUpCombine() -> AnyPublisher<MinSecAndFraction, Error>
    {
        let retval = Timer.publish(every: tickInterval,
                                   tolerance: tickTolerance,
                                   on: .main, in: .common)
            .autoconnect()
//            .print()
            .tryMap {
                // Timer's date to seconds until expiry
                (date: Date) -> TimeInterval in
                let retval = self.endingDate.timeIntervalSince(date)
                guard retval >= 0 else {
                    throw TerminationErrors.expired
                }
                return retval
            }
            .map { rawInterval in
                // Seconds to expiry rounded by roundingScale
                let scaled = Self.roundingScale * rawInterval
                let trimmed = round(scaled)
                let rescaled = trimmed / Self.roundingScale
                return rescaled
            }
            .map {
                // Rounded seconds to expiry to MinSecAndFraction
                (tInterval: TimeInterval) -> MinSecAndFraction in
                let intInterval = Int(trunc(tInterval))
                return MinSecAndFraction(
                    minute: intInterval / 60,
                    second: intInterval % 60,
                    fraction: tInterval - trunc(tInterval)
                )
            }
            .eraseToAnyPublisher()
        return retval
    }
}

