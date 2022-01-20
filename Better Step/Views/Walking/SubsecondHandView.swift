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
    @State var sweepTimer: Timer?
    var body: some View {
        GeometryReader { proxy in
            Rectangle()
                .rotation(
                    Angle(degrees: 180.0 + (normalizedAngle * 360.0)),
                          anchor: UnitPoint(x: 0.5, y: 0.05))
                .frame(width: 2.0, height: proxy.size.short, alignment: .center)
        }
        
        .onAppear {
            sweepTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { t in
                normalizedAngle += 0.01
            }
        }
    }
}

struct SubsecondHandView_Previews: PreviewProvider {
    static var previews: some View {
        SubsecondHandView(normalizedAngle: 0.4)
            .foregroundColor(.red)
            .frame(width: 100, height: 100, alignment: .center)
            .border(.green, width: 0.5)
    }
}
