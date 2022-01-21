//
//  SubsecondHandView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/20/22.
//

import SwiftUI
import CoreGraphics

struct SubsecondHandView: View {
    @State var normalizedAngle: CGFloat
    @EnvironmentObject var timer: WrappedTimer

    func midpoint(within proxy: GeometryProxy) -> CGPoint {
        let middle = proxy.size.short / 2.0
        return CGPoint(x: middle, y: middle)
    }

    var body: some View {
        GeometryReader { proxy in
            Rectangle()
                .rotation(
                    Angle(degrees: 180.0 + (timer.fractionalSeconds * 360.0)),
                          anchor: UnitPoint(x: 0.5, y: 0.05))
                .offset(midpoint(within: proxy))
                .frame(width: 2.0, height: proxy.size.short/2.0, alignment: .center)
        }
    }
}

struct SubsecondHandView_Previews: PreviewProvider {
    static func previewWT() -> WrappedTimer {
        let retval = WrappedTimer(5.0)
        return retval
    }

    static var previews: some View {
        SubsecondHandView(normalizedAngle: 0.4)
            .foregroundColor(.red)
            .frame(width: 100, height: 100, alignment: .center)
            .border(.green, width: 0.5)
            .environmentObject(previewWT())
    }
}
