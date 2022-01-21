//
//  WrappedTimer.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/21/22.
//

import Foundation
import Combine

final class WrappedTimer: ObservableObject {
    let originalTimePublisher: Timer.TimerPublisher
    let timePublisher: AnyPublisher<Timer.TimerPublisher.Output, Never>

    @Published var seconds: TimeInterval
    @Published var fractionalSeconds: TimeInterval
    @Published var integerSeconds: Int
    @Published var downSeconds: Int

    @Published var expired: Bool

    let startDate: Date
    let endDate: Date
    let countdownInterval: TimeInterval

    static var cancellables: Set<AnyCancellable> = []

    init(_ limit: TimeInterval) {
        (seconds, integerSeconds, fractionalSeconds) = (0, 0, 0)
        downSeconds = Int(limit.rounded(.down))
        countdownInterval = limit
        startDate = Date()
        endDate = startDate.addingTimeInterval(limit)
        expired = false
        let original = Timer.publish(every: 0.01, tolerance: 0.005,
                                              on: .main, in: .default, options: nil)
        originalTimePublisher = original
        timePublisher = original.autoconnect().eraseToAnyPublisher()

        setUpCombine()
    }

    var timerCancellable: AnyCancellable?

    func setUpCombine() {
        timerCancellable = timePublisher.sink { [self] date in
            self.seconds = date.timeIntervalSince(self.startDate)
            self.integerSeconds = Int(self.seconds.rounded(.towardZero))
            self.fractionalSeconds = self.seconds - Double(self.integerSeconds)
            self.downSeconds = Int(self.countdownInterval - Double(self.integerSeconds))

            if Date() >= endDate { haltTimer(); return }
        }
        timerCancellable!
            .store(in: &Self.cancellables)
    }

    func haltTimer() {
        expired = true
        timerCancellable?.cancel()
    }
}


