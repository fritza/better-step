//
//  Timekeeper.swift
//  Better Step
//
//  Created by Fritz Anderson on 10/10/22.
//

import Foundation
import Combine

/*

 Frankly, a complete rewrite replacing MinutePublisher and TimeReader, now that the timekeeping strategy is clear
 * Rebuild the timing chains (unit-specific Subscriber-Publisher chains whenever a count is to start.
 * Use Status as an Error as well. Throw .completed and .cancelled when you need to stop. The throw will cancel the timer.

 */

// MARK: - class Timekeeper
final class Timekeeper: ObservableObject {
    // MARK: Status
    enum Status: Error, CustomStringConvertible {
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

    // MARK: TimingSpec
    struct TimingSpec {
        let duration, increment, tolerance, roundingScale : TimeInterval
        let units: Units
        init(duration       : TimeInterval,
             increment      : TimeInterval = 0.05,
             tolerance      : TimeInterval = 0.02,
             roundingScale  : TimeInterval = 100.0,
             units          : Units = .all) {
            self.duration      = duration
            self.increment     = increment
            self.tolerance     = tolerance
            self.roundingScale = roundingScale
            self.units         = units
        }
    }

    // MARK: Units
    struct Units: RawRepresentable, OptionSet {
        let rawValue: Int
        init(rawValue: Int) { self.rawValue = rawValue }

        static let minutes    = Units(rawValue: 1)
        static let seconds    = Units(rawValue: 2)
        static let fraction   = Units(rawValue: 4)
        static let all: Units = [.minutes, .seconds, .fraction]
    }

    // MARK: Properties
    private let duration, increment, tolerance, roundingScale: TimeInterval
    var startTime, deadline: Date!
    var units: Units

    // MARK: Published
    @Published var status: Status
    @Published var minutes: Int
    @Published var seconds: Int
    @Published var fraction: TimeInterval
    // TODO: Why no minutes+seconds for "mm:ss"?

    // MARK Initializers
    convenience init(duration: TimeInterval,
                     increment      : TimeInterval = 0.05,
                     tolerance      : TimeInterval = 0.02,
                     roundingScale  : TimeInterval = 100.0,
                     units          : Units) {
        let specs = TimingSpec(duration: duration, increment: increment,
                               tolerance: tolerance, roundingScale: roundingScale,
                               units: units)
        self.init(specs)
    }

    init(_ spec: TimingSpec) {
        self.duration      = spec.duration
        self.increment     = spec.increment
        self.tolerance     = spec.tolerance
        self.roundingScale = spec.roundingScale
        self.units         = spec.units

        self.status = .idle
        (self.minutes, self.seconds, self.fraction) = (0, 0, 0)
    }

    // MARK: - Life cycle

    func start() {
        startTime = Date()
        deadline  = startTime + duration
        rootPublisher = makeRootPublisher()
        if units.contains(.fraction)  { handleFractions() }
        if units.contains(.seconds )  { handleSeconds()   }
        if units.contains(.minutes )  { handleMinutes()   }
    }

    func cancel() {
        self.status = .cancelled

    }

    // MARK: - Combine
    var cancellables: Set<AnyCancellable> = []

    private var rootPublisher: AnyPublisher<MinSecAndFraction, Error>!
    // MARK: Root
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
                guard !self.cancelled else { throw Status.cancelled }
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
            .eraseToAnyPublisher()
        return secSource
    }

    // MARK: Minutes
    private func handleMinutes() {
        rootPublisher
            .map { $0.minute }
            .removeDuplicates()
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    if let error = error as? Status {
                        self.status = error
                    }
                    else {
                        self.status = .unknown
                    }
                }
            }
    receiveValue: {
        self.minutes = $0
    }
    .store(in: &cancellables)
    }

    // MARK: Seconds
    private func handleSeconds() {
        rootPublisher
            .map { $0.second }
            .removeDuplicates()
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    if let error = error as? Status {
                        self.status = error
                    }
                    else {
                        self.status = .unknown
                    }
                }
            }
    receiveValue: {
        self.seconds = $0
    }
    .store(in: &cancellables)
    }

// MARK: Fractions
    private func handleFractions() {
        rootPublisher
            .map { $0.fraction }
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    if let error = error as? Status {
                        self.status = error
                    }
                    else {
                        self.status = .unknown
                    }
                }
            }
    receiveValue: {
        self.fraction = $0
    }
    .store(in: &cancellables)
    }
}
