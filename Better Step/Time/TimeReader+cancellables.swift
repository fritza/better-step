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
    static func createSharedTimePublisher() -> AnyPublisher<MinSecAndFraction, Error>
    {
        let retval = Timer.publish(every: tickInterval,
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
            .share()
            .eraseToAnyPublisher()

        sharedTimer      = retval
        timePublisher    = retval // ???
        mmssPublisher    = mmss_00_Timer()
        secondsPublisher = ss_Timer()
        fractionsPublisher = fff_Timer()
         */

        return retval
    }

    func ss_Timer() -> AnyPublisher<Int, Error> {
        let retval = Self.sharedTimePublisher
            .map { $0.second }
            .filter { $0 >= 0 }
            .removeDuplicates()
            .eraseToAnyPublisher()


        return retval

        /*
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
        */
    }

    func fff_Timer() -> AnyPublisher<Double, Error> {
        let retval = Self.sharedTimePublisher
            .map { (mmssfff: MinSecAndFraction) -> Double in
                return mmssfff.fraction
            }
            .eraseToAnyPublisher()
        return retval
    }
//            .sink { completion in
//                switch completion {
//                case .finished: break
//                case .failure(let error):
//                    guard let err = error as? TerminationErrors else {
//                        //                        print("Timer serial", self.serial, ": other error: \(error).")
//                        return
//                    }
//                    switch err {
//                    case .expired:
//                        self.status = .expired
//                        //print("Timer serial", self.serial, "ran out")
//                    case .cancelled:       // print("Timer serial", self.serial, "was cancelled")
//                        self.status = .cancelled
//                    }
//                }
//            } receiveValue: { msf in
//                self.timeSubject.send(msf)
//            }

    func mmss_00_Timer() ->  AnyPublisher<MinSecAndFraction, Error> {
        //        var lastMMSS = MinSecAndFraction.zero
        let retval = Self.sharedTimePublisher
            .removeDuplicates(by: {
                (lhs, rhs) -> Bool in
                return lhs.minute == rhs.minute &&
                lhs.second == rhs.second
            })
            .eraseToAnyPublisher()
        return retval
    }


        // An error can come from upstream when the timer expires.
        // Passthrough subjects (& current, I assume) can pass an Error down the chain.
        // This is probably a good idea.
        // So... why do my subjects say Never for the failure?
//            .replaceError(with: .zero)
        // They don't insist on Never. Now how do you subscribe so as to get the error from the subject?
        // You have to replace the onReceive to some kind of func expand(aSubject) -> Result<MinSecAndFraction>
        // Or func receivedValue(from: subject) throws -> MinSecAndFraction
//
//
//            .removeDuplicates()
//            .print("mmss_00")
//            .sink { mmssfff in  // <- obsolete
//                self.mmssSubject.send(mmssfff)
//            }

}


