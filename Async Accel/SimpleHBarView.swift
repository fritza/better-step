//
//  SimpleHBarView.swift
//  Async Accel
//
//  Created by Fritz Anderson on 3/28/22.
//

import SwiftUI
import CoreMotion

struct SimpleHBarView: View {
    let logRange: ClosedRange<Double>

    init(gRange: ClosedRange<Double>,
         datum: CMAcceleration) {
       logRange = log(gRange.lowerBound)
       ...
       log(gRange.upperBound)

        currentDatum = datum
    }

    var currentDatum: CMAcceleration = CMAcceleration()
    var scalarAcceleration: Double {
        func squared(_ dbl: Double) -> Double {
            dbl*dbl
        }
        let scalar = [squared(currentDatum.x),
                      squared(currentDatum.y),
                      squared(currentDatum.z)
                      ]
            .reduce(0.0, +)
        return sqrt(scalar)
    }

    func asNormalizedLog() -> Double {
        let spread = logRange.upperBound - logRange.lowerBound
        let pinnedLog = log(scalarAcceleration).pinned(to: logRange)
        let zero = abs(logRange.lowerBound) / spread
        return zero + pinnedLog/spread
    }

    private let backGradient = Gradient(colors: [
        Color(UIColor(white: 0.91, alpha: 1.0).cgColor),
        Color(UIColor(white: 0.80, alpha: 1.0).cgColor)
        ]
    )

    private let barGradient = Gradient(colors: [
        Color(UIColor(hue: 0.0, saturation: 0.7,
                      brightness: 0.8, alpha: 1.0)
            .cgColor),
        Color(
            UIColor(hue: 0.0, saturation: 0.6,
                    brightness: 0.97, alpha: 1.0)
            .cgColor)
    ]
    )

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                // Background shape
                Rectangle().fill(
                    .linearGradient(
                        backGradient,
                        startPoint: UnitPoint(x: 0.0, y: 1.0),
                        endPoint: UnitPoint(x: 0.0, y: 0)))

                // Foreground shape
                Rectangle().fill(
                    .linearGradient(
                        barGradient,
                        startPoint: UnitPoint(x: 0.0, y: 1.0),
                        endPoint: UnitPoint(x: 0.0, y: 0.0)))
                    .frame(
                        width: asNormalizedLog()*proxy.size.width,
                        height:
                            [0.5 * proxy.size.height,
                             proxy.size.height - 2.0]
                            .min()!,
                        alignment: .center)
            }
        }
    }
}

struct SimpleHBarBiew_Previews: PreviewProvider {
    static var previews: some View {
        SimpleHBarView(gRange: 0.01...1.75,
                       datum : CMAcceleration(x: 0.2, y: 1.3, z: -1)
        )
            .frame(width: 300.0, height: 20.0, alignment: .leading)
    }
}
