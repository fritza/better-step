//
//  WrappedTimer.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/21/22.
//

import Foundation
import Combine

func isolation() -> AnyPublisher<Timer.TimerPublisher.Output, Never> {
    let tp = Timer.publish(every: 0.01, tolerance: 0.005, on: .main, in: .default, options: nil)
        .autoconnect()
        .eraseToAnyPublisher()
    return tp
}

final class WrappedTimer: ObservableObject {
    let timePublisher: AnyPublisher<Timer.TimerPublisher.Output, Never>
    @Published var seconds: TimeInterval
    @Published var fractionalSeconds: TimeInterval
    @Published var integerSeconds: Int
    @Published var downSeconds: Int
    let startDate: Date
    let countdownInterval: TimeInterval

    static var cancellables: Set<AnyCancellable> = []

    init(_ limit: TimeInterval) {
        (seconds, integerSeconds, fractionalSeconds) = (0, 0, 0)
        downSeconds = Int(limit.rounded(.down))
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
            self.downSeconds = Int(self.countdownInterval - Double(self.integerSeconds))
        }
        .store(in: &Self.cancellables)
    }
}


