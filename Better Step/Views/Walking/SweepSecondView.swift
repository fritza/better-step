//
//  SweepSecondView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/20/22.
//

import SwiftUI
import Combine

extension CGSize {
    var short: CGFloat {
        [width, height].min()!
    }
    var long: CGFloat {
        [width, height].max()!
    }
}

func isolation() -> AnyPublisher<Timer.TimerPublisher.Output, Never> {
    let tp = Timer.publish(every: 1, tolerance: 0.01, on: .main, in: .default, options: nil)
        .autoconnect()
        .eraseToAnyPublisher()
    return tp
}

final class WrappedTimer: ObservableObject {
    let publisher: AnyPublisher<Timer.TimerPublisher.Output, Never>
    @Published var seconds: TimeInterval
    @Published var downSeconds: TimeInterval
    let startDate: Date

//    public let secondsSubject: CurrentValueSubject<TimeInterval, Never>

    static var cancellables: Set<AnyCancellable> = []
    init(_ limit: TimeInterval) {
        seconds = 0
        downSeconds = limit
        publisher = isolation()
        startDate = Date()

//        secondsSubject = CurrentValueSubject<TimeInterval, Never>(5)
//
//        publisher
//            .sink { date in
//                self.secondsSubject.send(date.timeIntervalSince(self.startDate))
//            }
//            .store(in: &Self.cancellables)
    }

}

struct SweepSecondView: View {
    @State var seconds: Int
    @EnvironmentObject var timer: WrappedTimer

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .center) {
                Circle()
                    .stroke(lineWidth: 1.0)
                    .foregroundColor(.gray)
                    .frame(width: proxy.size.short * 0.95,
                           height: proxy.size.short * 0.95,
                           alignment: .center)
                Text("\(seconds)")
                    .font(.system(size: proxy.size.short * 0.6, weight: .semibold, design: .default))
            }
        }
        //        .onReceive(timer.secondsSubject) { interval in
        //            seconds = Int(round(interval))
        //        }
    }
}

struct SweepSecondView_Previews: PreviewProvider {
    static var previews: some View {
        //        HStack {Spacer()
        SweepSecondView(seconds: 5)
            .frame(width: 300)
            .environmentObject(WrappedTimer(5))
        //            Spacer()}
    }
}
