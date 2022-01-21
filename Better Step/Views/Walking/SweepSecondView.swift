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

struct SweepSecondView: View {
    @State var seconds: Double
    @State var fractions: Double
    static var cancellables: Set<AnyCancellable> = []
    @EnvironmentObject var timer: WrappedTimer

    init(seconds: TimeInterval) {
        self.seconds = seconds
        self.fractions = seconds - seconds.rounded(.towardZero)

        timer.$fractionalSeconds.sink { frac in
            self.fractions = frac
        }
        .store(in: &Self.cancellables)
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .center) {
                Circle()
                    .stroke(lineWidth: 1.0)
                    .foregroundColor(.gray)
                    .frame(width: proxy.size.short * 0.95,
                           height: proxy.size.short * 0.95,
                           alignment: .center)
                SubsecondHandView(
                    normalizedAngle:
                        timer.fractionalSeconds)
                Text("\(seconds)")
                    .font(.system(size: proxy.size.short * 0.6, weight: .semibold, design: .default))
            }
        }
    }
}

struct SweepSecondView_Previews: PreviewProvider {
    static func previewWrappedTimer() -> WrappedTimer {
        return WrappedTimer(5)
    }
    static var previews: some View {
        SweepSecondView(seconds: 5)
            .frame(width: 300)
            .environmentObject(previewWrappedTimer())
    }
}
