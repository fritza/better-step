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
    func setUpCombine() -> AnyPublisher<MinSecAndFraction, Error>
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
            .eraseToAnyPublisher()
        return retval
    }

    func ss_Cancellable() -> AnyCancellable {
        let retval = sharedTimer
            .map { $0.second }
            .filter { $0 >= 0 }
            .removeDuplicates()

            .print("seconds")

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
        return retval
    }

    func mmss_ff_Cancellable() -> AnyCancellable {
        let retval = sharedTimer
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
        return retval
    }

    func mmss_00_Cancellable() ->  AnyCancellable {
//        var lastMMSS = MinSecAndFraction.zero
        let retval = sharedTimer
            .map { time in
                return time.with(fraction: 0.0)
            }
            .replaceError(with: .zero)
//            .filter {
//                $0.second % CountdownConstants.countdownInterval
//                == 0
//            }
//            .breakpointOnError()
//            .breakpoint(receiveOutput: {
//                output in
//                guard lastMMSS != .zero &&
//                        output != .zero else { return false }
//                if output == lastMMSS { return true }
//                lastMMSS = output
//                return false
//            })
            .removeDuplicates()
            .print("mmss_00")
            .sink { mmssfff in
                self.mmssSubject.send(mmssfff)
            }
        return retval
    }


}


