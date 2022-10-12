//
//  SubsecondHandView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/20/22.
//

import SwiftUI

/**
 ## Topics

 ### Properties
 - ``fractionalSecond``
 - ``body``
 */

/// A thin rectangle that can be rotated through a circle, given fractions of 360º.
///
/// The expected use is as a clock hand indicating fractions of a second.
struct SubsecondHandView: View {
    /// The desired position of the hand , _counterclockwise,_ in `0.0..<1.0`
    let fractionalSecond: TimeInterval

    private func midpoint(within proxy: GeometryProxy) -> CGPoint {
        let middle = proxy.size.short / 2.0
        return CGPoint(x: middle, y: middle)
    }

    var body: some View {
        GeometryReader { proxy in
            // The "hand" is a narrow rectangle
            // rotating near one end on the center
            // of the superview.
            Rectangle()
                .rotation(
                    Angle(degrees:
                            180.0 + fractionalSecond * 360.0 ),
                    anchor: UnitPoint(x: 0.5, y: 0.05))
                .offset(midpoint(within: proxy))
                .frame(width: 2.0, height: proxy.size.short/2.0, alignment: .center)
        }
    }
}

struct SubsecondHandView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack {
                ForEach(0..<10) { tick in
                    HStack(alignment: .top) {
                        Text("\(tick)/9").font(.headline)
                        SubsecondHandView(fractionalSecond: Double(tick)/9.0)
                            .foregroundColor(.red)
                            .frame(width: 100, height: 100, alignment: .center)
                            .border(.green, width: 0.5)
                    }
                }
            }
        }
        .padding()
    }
}
