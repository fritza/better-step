//
//  SweepSecondView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/20/22.
//

import SwiftUI
import Combine

struct SweepSecondView: View {
    @EnvironmentObject var timer: WrappedTimer

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .center) {
                Circle()
                    .stroke(lineWidth: 1.0)
                    .foregroundColor(.gray)
                SubsecondHandView()
                Text("\(timer.downSeconds)")
                    .font(.system(size: proxy.size.short * 0.6, weight: .semibold, design: .default))
            }
            .frame(width: proxy.size.short * 0.95,
                   height: proxy.size.short * 0.95,
                   alignment: .center)
        }
    }
}

struct SweepSecondView_Previews: PreviewProvider {
    static func previewWrappedTimer() -> WrappedTimer {
        return WrappedTimer(5)
    }
    static var previews: some View {
        SweepSecondView()
            .frame(width: 300)
            .environmentObject(previewWrappedTimer())
    }
}
