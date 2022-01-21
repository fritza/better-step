//
//  WrappedTimer.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/21/22.
//

import Foundation
import Combine

func isolation() -> AnyPublisher<Timer.TimerPublisher.Output, Never> {
    let tp = Timer.publish(every: 1, tolerance: 0.01, on: .main, in: .default, options: nil)
        .autoconnect()
        .eraseToAnyPublisher()
    return tp
}

final class WrappedTimer: ObservableObject {
    let timePublisher: AnyPublisher<Timer.TimerPublisher.Output, Never>
    @Published var seconds: TimeInterval
    @Published var fractionalSeconds: TimeInterval
    @Published var integerSeconds: Int
    @Published var downSeconds: TimeInterval
    let startDate: Date
    let countdownInterval: TimeInterval

    static var cancellables: Set<AnyCancellable> = []

    init(_ limit: TimeInterval) {
        (seconds, integerSeconds, fractionalSeconds) = (0, 0, 0)
        downSeconds = limit
        countdownInterval = limit
        timePublisher = isolation()
        startDate = Date()

        setUpCombine()
    }

    func setUpCombine() {
        timePublisher.sink { date in
            self.seconds = date.timeIntervalSince(self.startDate)
            self.integerSeconds = Int(self.seconds.rounded(.towardZero))
            self.fractionalSeconds = self.seconds - Double(self.integerSeconds)
            self.downSeconds = self.seconds - self.countdownInterval
        }
        .store(in: &Self.cancellables)
    }
}


