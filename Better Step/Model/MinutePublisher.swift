//
//  MinutePublisher.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/6/22.
//

import Foundation
import Combine

// TODO: The count-up should also stop the clock when a deadline is reached.
// TODO: set up for fractions only if they will be used.
//       Otherwise, the subscriber need not be created,
//       and maybe the Timer can be given a looser interval and tolerance.

// MARK: - MinutePublisher
/// Publisher of components of `Timer` ticks in `Int` minutes and seconds, and `Double` subseconds, counting up or down.
///
/// Countdown timers run for a specified duration into the future. The duration — deadline — may be set as an interval to an ending time, or a `Date` deadline.
///
/// Count-up timers run indefinitely.
///
/// The published outputs are components of "clock time" (not fo be confused with kernel-level "clock" timing) toward the deadline, truncated minutes, seconds, and fractional seconds.
///
/// When the deadline is reached, `completedSubject` carries a `Bool` indicating whether the clock ran out vs. cancelled.
///
/// - bug: The count-up should also stop the clock when a deadline is reached.
final class MinutePublisher: ObservableObject {
    var cancellables: Set<AnyCancellable> = []

    // MARK: Subjects
    // The minute, second, and fraction subjects were of the form
    // var minuteSubject   = PassthroughSubject<Int   , Never>()

    /// Subscribers get a `Bool` input when the set period ends through exhaustion or by clients' calling `.stop()`. The `Bool` is true iff the completion is due to exhaustion.
    var completedSubject = PassthroughSubject<Bool, Never>()

    /// The root time publisher with default parameters:
    /// * every 0.01 seconds...
    /// * ... ± 0.03 sconds (**NOTE**: a substantial amount of slack)
    /// * current run loop
    /// * in `.common` mode
    private let timePublisher = Timer.publish(
        every: 0.01, tolerance: 0.03,
        on: .current, in: .common)

    // MARK: @Published
    @Published var minutes: Int = 0
    @Published var seconds: Int = 0
    @Published var fraction: Double = 0.0

    // MARK: Initialization

    private let countdownTo: Date?
    /// Initialize a countdown toward a future date, or a count-up from the present.
    /// - parameter date: The deadline as `Date` to count down to. If `nil` (the default), the clock counts up indefinitely from the current date.
    init(to date: Date? = nil) {
        countdownTo = date
    }

    /// Initialize a count**down** to a future time that is a certain interval from now.
    /// - parameter interval: The interval between now and the time to which the clock will count down.
    convenience init(after interval: TimeInterval) {
        let date = Date(timeIntervalSinceNow: interval)
        self.init(to: date)
    }

    /// The `Date` at which `start()` commenced the count. Used only as a reference point for counting up.
    private var started: Date!
    /// The time publisher, converted to emitting a `TimeInterval` between now and the deadline.
    var commonPublisher: AnyPublisher<TimeInterval, Never>!

    // MARK: start
    /// Set up subscriptions to (ultimately) the `Timer.Publisher` and start the clock.
    ///
    /// The shared time publisher (`commonPublisher`) emits the current interval to the deadline, and calls `.stop()` if this instance is a countdown timer and the deadline is reached. The fraction, seconds, and minutes subscribe to it.
    func start() {
        started = Date()

        // Subscribe to the timer, correct to count-down or -up, and check for deadlines.
        commonPublisher = timePublisher
            .autoconnect()
            .map {
                currentDate -> TimeInterval in
                if let remote = self.countdownTo {
                    if currentDate >= remote { self.stop() }
                    return -currentDate.timeIntervalSince(remote)
                }
                else {
                    return currentDate.timeIntervalSince(self.started)
                }
            }
            .share()
            .eraseToAnyPublisher()

        // Emit fractions
        commonPublisher
            .map { $0 - Double( Int($0) ) }
            .sink { fraction in
                self.fraction = fraction
            }
            .store(in: &cancellables)

        // Emit seconds
        commonPublisher
            .map { Int($0) % 60 }
            .removeDuplicates()
            .sink { seconds in
                self.seconds = seconds
            }
            .store(in: &cancellables)

        // emit minutes
        commonPublisher
            .map { Int($0) / 60 }
            .removeDuplicates()
            .sink { minutes in
                self.minutes = minutes
            }
            .store(in: &cancellables)
    }

    // MARK: Stop
    /// Halt the clock and send a `Bool` to `completedSubject` to indicate exhaustion or halt.
    ///
    /// - parameter exhausted: `true` iff `stop()` was called because the clock ran out. This is passed along through `completedSubject` to inform clients the clock is finished.
    func stop(exhausted: Bool = false) {
        for c in cancellables {
            c.cancel()
            completedSubject.send(exhausted)
        }
    }
}

