//
//  Timekeeper.swift
//  Better Step
//
//  Created by Fritz Anderson on 10/10/22.
//

import Foundation
import Combine

// MARK: - CountdownConstants

/// Constants for time intervals, as for
///
/// * Duration of walk tests
/// * Durtation of the sweep-second counttdown to walk tests
/// * Time between announcements of time-remaining in a walk (obsolete)
/// * Sampling rate and precision for Core Motion and clocks.
enum CountdownConstants {
    /// Total duration of a walk phase. This may be shorter in debugging views, because waiting a whole two minutes just to check out the view is a drag.
#if DEBUG
    static let walkDuration    = 120.0
// Would like this to be 20 or something, but I suspect the transitiion tp walk_2 isn't possible until the walk_1 audio is finished.
#else
    static let walkDuration    = 120.0
#endif
    /// Time between spoken progress announcements in a walk
    @available(*, unavailable, message: "Remaining walk time is no longer announced")
    static let countdownInterval    = 30
    /// Total seconds in the countdown to commencement of walk
    static let sweepDuration        = 5.0

    /// Collection rate for Core Motion accelerometry.
    static let hz                : UInt64 = 60
    /// Timing between accelerometry readings.
    static let hzInterval        : Double = 1.0/Double(hz)
    /// The interval for between `Timer` updates for updating the UI. See `Timer`.
    static let timerTick         : Double = hzInterval*2.0
    /// Tolerated variance ± from strict regularity in `Timer` notifications. See `Timer`.
    static let timerTolerance    : Double = timerTick/8.0
    /// Duration in ns between `Task.sleep(nanoseconds:)` updates of the `AsyncStream` values for `for async`. Twice as frequent as the requested update (.`timerTick` interval.
    static let nanoSleep         : UInt64 = UInt64(hzInterval * Double(NSEC_PER_SEC) / 2.0)

    /// `Timer`-provided second marks arrive at unlimited precision. ``Timekeeper`` rounds thest to this fraction of a second.
    static let secondsRoundingFactor = 100.0

    /// Delay in displaying `SweepSecondView` till the ``AudioMilestone`` catches up.
    static let sweepSecondDelay = 1.1
}



/**
 ## Topics

 ### Published
 - ``status``
 - ``minutes``
 - ``seconds``
 - ``minuteSecondString``
 - ``fraction``

 ### Life Cycle
 - ``start()``
 - ``cancel()``

 ### Initializers
 - ``init(_:)``
 - ``init(duration:increment:tolerance:roundingScale:units:)``
 - ``TimingSpec/duration``
 - ``TimingSpec/increment``
 - ``TimingSpec/tolerance``
 - ``TimingSpec/roundingScale``
 - ``TimingSpec/units``
 - ``TimingSpec/init(duration:increment:tolerance:roundingScale:units:)

 ### Units
 - ``Units/minutes``
 - ``Units/seconds``
 - ``Units/fraction``
 - ``Units/mmssString``

### Status
 - ``Status-swift.enum/idle``
 - ``Status-swift.enum/running``
 - ``Status-swift.enum/cancelled``
 - ``Status-swift.enum/completed``
 - ``Status-swift.enum/unknown``
 */


// MARK: - class Timekeeper
/// Common source of truth for a countdown timer. ``Timekeeper`` breaks the clock time into minutes, seconds, and other components that clients can use to populate `View`s.
final class Timekeeper: ObservableObject {
    /// Status fof the life cycle of the object.
    ///
    /// `Timekeeper.Status` doubles as readable progress and as an `Error` that will cancel the stream. This includes expiry of the countdown `.completed` and user cancellation `.cancelled`..
    ///
    /// Throwing an error in a Combine chain propagates up to cancelling the `Timer` publisher. Clients of any of the published attributes will receive the reason for termination as a `.failure`  error in the `receiveCompletion` branch of `.sink`.
    enum Status: Error, CustomStringConvertible {
        // MARK: - Status
        case idle, running, completed, cancelled, unknown
        var description: String {
            switch self {
            case .idle:      return "idle"
            case .running:   return "running"
            case .completed: return "completed"
            case .cancelled: return "cancelled"
            case .unknown:   return "unknown error"
            }
        }
    }

    /// Parameters for a countdown (duration, tick interval, tolerance, rounding, units requested).
    ///
    /// Initialize `TimeKeeper` with a `TimingSpec`. ``Timekeeper`` has an additional initializer for specifying these as parameters.
    struct TimingSpec {
        // MARK: - TimingSpec
        let duration, increment, tolerance, roundingScale : TimeInterval
        let units: Units
        init(duration       : TimeInterval,
             increment      : TimeInterval = CountdownConstants.timerTick,
             tolerance      : TimeInterval = CountdownConstants.timerTolerance,
             roundingScale  : TimeInterval = CountdownConstants.secondsRoundingFactor,
             units          : Units) {
            self.duration      = duration
            self.increment     = increment
            self.tolerance     = tolerance
            self.roundingScale = roundingScale
            self.units         = units
        }
    }

    /// Units (by-minute, by-second, by-fraction) for which Combine `Publisher`s will be created..
    ///
    /// Clients should not examine publishers whose unuts have not been requested. The clock will not update them.
    /// - note: If  `Units` contains _both_ `.minutes` and `.seconds`, ``Timekeeper`` will _additonally_ generate a stream for the string `"mm:ss"`. _See_ ``Timekeeper/start()``.
    struct Units: RawRepresentable, OptionSet, CustomStringConvertible {
        // MARK: - Units
        let rawValue: Int
        init(rawValue: Int) { self.rawValue = rawValue }

        var description: String {
            var strings: [String] = []
            if self.contains(.minutes )        { strings.append("minutes" ) }
            if self.contains(.seconds )        { strings.append("seconds" ) }
            if self.contains(.fraction)        { strings.append("fraction") }
            if self.contains(.mmSecondsString) { strings.append("mm:ss"   ) }

            guard !strings.isEmpty else { return "<none>"}
            return "[ " + strings.joined(separator: ", ") + " ]"
        }

        static let minutes         = Units(rawValue: 1)
        static let seconds         = Units(rawValue: 2)
        static let fraction        = Units(rawValue: 4)
        static let mmSecondsString = Units(rawValue: 8)
        static let all: Units = [.minutes, .seconds, .fraction, .mmSecondsString]
    }

    // MARK: Properties (state)

    private let duration, increment, tolerance, roundingScale: TimeInterval
    private var startTime, deadline: Date!
    private var units: Units

    // MARK: Properties (published)
    /// The stage (`idle`, `completed`, etc.) of the life cycle. Initially `idle`
    @Published var status: Status
    /// The whole number of minutes remaining in the countdown. Initially 0.
    @Published var minutes: Int
    /// The whole number of seconds within a minute remaining in the countdown. Initially 0.
    @Published var seconds: Int
    /// A `String` denoting `minutes` and `seconds` in the form "mm:ss". Initially "xx:xx".
    @Published var minuteSecondString: String
    /// The fraction of a second within the minutes and seconds remaining in the countdown. Initially 0.0.
    @Published var fraction: TimeInterval

    // MARK Initializers
    /// Initialize a ``Timekeeper`` with internal state variables specified individually.
    ///
    /// For details on the parameters, see `Timer`.
    /// - Parameters:
    ///   - duration: The amount of time the countdown is to run. (e.g. 120 seconds). This is not defaulted.
    ///   - increment: The increment within the duration at which the underlying `Timer` emits time. Default is `CountdownConstants.timerTick`, (`1/30` of a second ATW).
    ///   - tolerance: The maximum amount the emitted time may vary from the strict increment. See `Timer`. Defaults to `CountdownConstants.timerTolerance` (`1/240` second ATW).
    ///   - roundingScale: The divisor by which to round the Timer's reported time . Defaults to `100.0` (`5.12345 -> 5.123`)
    ///   - units: The time components to be updated during the lifetime of the ``Timekeeper``.  `seconds`, for instance, will not be updated if `.seconds` is not included. If  `Units` contains _both_ `.minutes` and `.seconds`, ``Timekeeper`` will _additonally_ update `"mm:ss"` (`minuteSecondString`). Not defaulted.
    convenience init(duration       : TimeInterval,
                     increment      : TimeInterval = CountdownConstants.timerTick,
                     tolerance      : TimeInterval = CountdownConstants.timerTolerance,
                     roundingScale  : TimeInterval = CountdownConstants.secondsRoundingFactor,
                     units          : Units) {
        let specs = TimingSpec(duration: duration, increment: increment,
                               tolerance: tolerance, roundingScale: roundingScale,
                               units: units)
        self.init(specs)
    }

    /// Initialize a ``Timekeeper`` from a `TimingSpec` `struct` encompassing all the configuration values. _See_ ``Timekeeper/TimingSpec`` for defaults.
    init(_ spec: TimingSpec) {
        self.duration      = spec.duration
        self.increment     = spec.increment
        self.tolerance     = spec.tolerance
        self.roundingScale = spec.roundingScale
        self.units         = spec.units

        self.status = .idle
        (self.minutes, self.seconds, self.fraction, self.minuteSecondString) = (0, 0, 0, "xx:xx")
    }

    // MARK: - Life cycle

    /// Generate streams to update the `@Publisher` propterties. Only the properties requested as units in the initializer are generated.
    ///
    /// `status` will be set to `.running`. Countdown will cpmmence immediately. It will stop (and set a `.failure` completion) upon `cancel()` or expiration..
    /// - warning: Properties not among the requested uinits are undefined
    /// - note: If  `Units` contains _both_ `.minutes` and `.seconds`, ``Timekeeper`` will _additonally_ generate a stream to update `minuteSecondString` (`"mm:ss"`).
    func start() {
        status = .running

        startTime = Date()
        deadline  = startTime + duration
        rootPublisher = makeRootPublisher()
        if units.contains(.minutes          ) { handleMinutes()    }
        if units.contains(.seconds          ) { handleSeconds()    }
        if units.contains(.fraction         ) { handleFractions()  }
        if units.contains(.mmSecondsString  ) { handleMinSeconds() }
    }

    /// Cancel the timer. All updates will halt; `rootPublisher` will see the `.cancelled` status and throw it.
    func cancel() {
        self.status = .cancelled
    }

    // MARK: - Combine
    /// The customary keep-alive holder for the results of the various `.sink`s.
    private var cancellables: Set<AnyCancellable> = []

    // MARK: Root
    /// The common `Publisher` driving all the `@Published` properties. It converts `Timer.Publisher` dates into `MinSecAndFraction` for further processing into derived time components.
    private var rootPublisher: AnyPublisher<MinSecAndFraction, Error>!
    /// Create the common `Publisher`of `MinSecAndFraction`for downstream operators to convert into `@Published` properties.
    private func makeRootPublisher() -> AnyPublisher<MinSecAndFraction, Error> {
        let secSource = Timer.publish(every: increment, on: .main, in: .common)
            .autoconnect()
            .tryMap { currentDate in
                // Bail if the deadline has been met
                guard currentDate <= self.deadline else {
                    self.status = .completed;
                    throw Status.completed
                }
                // Bail if client code has called cancel()
                guard self.status != .cancelled else { throw Status.cancelled }
                return self.deadline.timeIntervalSince(currentDate)
            }

        // -> TimeInterval (or thrown for expired or cancelled)
            .map { [self] (timeInterval: TimeInterval) -> TimeInterval in
                // Seconds to expiry rounded by roundingScale
                let scaled = roundingScale * timeInterval
                let trimmed = round(scaled)
                let rescaled = trimmed / roundingScale
                return rescaled
            }

        // -> Rounded TimeInterval
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

        // -> mins, secs, fraction
            .removeDuplicates {
                lhs, rhs in
                return lhs ≈≈ rhs
            }
            .share()
            .eraseToAnyPublisher()
        return secSource
    }

    // MARK: Minutes
    /// Sink downsteam from the root timer publisher, setting `self.minutes`.
    private func handleMinutes() {
        rootPublisher
            .map { $0.minute }
            .removeDuplicates()
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    guard let error = error as? Status else { self.unknown(error: error); return }
                    self.status = error
                }
            }
    receiveValue: {
        self.minutes = $0
    }
    .store(in: &cancellables)
    }

    // MARK: Seconds
    /// Sink downsteam from the root timer publisher, setting `self.seconds`.
    private func handleSeconds() {
        rootPublisher
            .map { $0.second }
            .removeDuplicates()
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    guard let error = error as? Status else { self.unknown(error: error); return }
                    self.status = error
                }
            }
    receiveValue: {
        self.seconds = $0
    }
    .store(in: &cancellables)
    }

    // MARK: "mm:ss"
    /// Sink downsteam from the root timer publisher, converting to `mm:ss` and setting `self.minuteSecondString`.
    private func handleMinSeconds() {
        rootPublisher
            .map {
                minSecFrac in
                return minSecFrac.with(fraction: 0.00)
            }
            .removeDuplicates()
            .map {
                minSecFrac in
                return minSecFrac.clocked
            }
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    guard let error = error as? Status else { self.unknown(error: error); return }
                    self.status = error
                }
            }
    receiveValue: {
        self.minuteSecondString = $0
    }
    .store(in: &cancellables)
    }

// MARK: Fraction
    /// Sink downsteam from the root timer publisher, setting `self.fraction` to the reported fraction-within second..
    private func handleFractions() {
        rootPublisher
            .map { $0.fraction }
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    guard let error = error as? Status else { self.unknown(error: error); return }
                    self.status = error
                }
            }
    receiveValue: {
        self.fraction = $0
    }
    .store(in: &cancellables)
    }

    /// Common code for `receiveCompletion` when the failure isn't cancellation or completion.
    private func unknown(error: Error, file: String = #fileID, line: Int = #line) {
        assertionFailure("Can't happen: error \(error) at \(file):\(line)")
        self.status = .unknown
    }
}
