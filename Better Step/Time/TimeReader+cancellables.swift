//
//  TimeReader+cancellables.swift
//  Better Step
//
//  Created by Fritz Anderson on 10/6/22.
//

import Foundation
import Combine

extension TimeReader {

    /// A `Publisher` that emits the `Timer`'s `Date` as minute/second/fraction at every tick.
    /// - Returns: The `Publisher` resulting from that chain.
    /* static */ func createSharedTimePublisher() -> AnyPublisher<MinSecAndFraction, Error>
    {
        let retval = Timer.publish(
            every: tickInterval,
                                   tolerance: tickTolerance,
                                   on: .main, in: .common)
            .autoconnect()
            .tryMap {
                // Timer's date to seconds until expiry
                (date: Date) -> TimeInterval in
                let retval = self.endingDate.timeIntervalSince(date)
                guard retval >= 0 else {
                    throw TerminationErrors.expired
                }
                return retval
            }
            .map { [self] rawInterval in
                // Seconds to expiry rounded by roundingScale
                let scaled = roundingScale * rawInterval
                let trimmed = round(scaled)
                let rescaled = trimmed / roundingScale
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
            .share()
            .eraseToAnyPublisher()
        return retval
    }

    private static var cancellables: Set<AnyCancellable> = []

    private /* static */ var areSubjectsInitialized: Bool {
        sharedTimePublisher != nil
    }

    private /* static */ func ss_Timer() -> AnyCancellable {
        let retval = sharedTimePublisher
            .replaceError(with: .zero)
            .removeDuplicates()
            .map { $0.second }
            .filter { $0 >= 0 }
            .eraseToAnyPublisher()
            .sink(receiveValue: { [self]
                secs in secondsSubject.send(secs)
            })
        return retval
    }

    /// The shared timer's output with the trailing zeros suppressed.
    private /* static */ func mmss00_Timer() -> AnyCancellable {
        let retval = sharedTimePublisher
            .replaceError(with: .zero)
            .removeDuplicates(by: { lhs, rhs in
                return lhs.second == rhs.second &&
                lhs.minute == rhs.minute
            })
            .map { mmssff in
                let retval = MinSecAndFraction(
                    minute: mmssff.minute,
                    second: mmssff.second,
                    fraction: 0.0)
                return retval
            }
            .eraseToAnyPublisher()
            .sink(receiveValue: { [self]
                secs in mmssSubject.send(secs)
            })
        return retval
    }

    private /* static */ func fff_Timer() -> AnyCancellable {
        let retval = sharedTimePublisher
            .replaceError(with: .zero)
            .removeDuplicates()
            .map { (mmssfff: MinSecAndFraction) -> Double in
                return mmssfff.fraction
            }
            .sink { [self] fracts in fractionsSubject.send(fracts) }
        return retval
    }

    private /* static */ func setUpCombine() {
        sharedTimePublisher = createSharedTimePublisher()
        ss_Timer().store(in: &Self.cancellables)
        mmss00_Timer().store(in: &Self.cancellables)
        fff_Timer().store(in: &Self.cancellables)
    }
}
        // An error can come from upstream when the timer expires.
        // Passthrough subjects (& current, I assume) can pass an Error down the chain.
        // This is probably a good idea.
        // So... why do my subjects say Never for the failure?
//            .replaceError(with: .zero)
        // They don't insist on Never. Now how do you subscribe so as to get the error from the subject?
        // You have to replace the onReceive to some kind of func expand(aSubject) -> Result<MinSecAndFraction>
        // Or func receivedValue(from: subject) throws -> MinSecAndFraction
