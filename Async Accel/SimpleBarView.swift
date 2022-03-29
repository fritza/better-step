//
//  SimpleBarView.swift
//  Async Accel
//
//  Created by Fritz Anderson on 3/10/22.
//

import SwiftUI

struct LogClipper {
    /// Inputs will be limited to ±`maxAbsoluteValue`. Out-of-range values will be clipped to the maximum absolute value.
    let maxAbsoluteValue: Double
    /// The height of the space available for drawing the value.
    let outputSpan: Double
    let ε = exp(-3.0) // 0.05 G

    func rescaling(_ value: Double) -> Double {
        let sign = value.sign
        let absoluteInput = abs(value)
        let logInput = log(absoluteInput)

/*
 Now I'm painted into a corner.
 What I want is to stack two rectangles, one for +a going up, one for -a going down. But if |a| is very small, log(a) → -∞.
 So: pin log(a) to ±0 below a certain ε. Say e⁻³ (0.05 G), maybe e⁻⁴ (0.02 G)

 Further: ln(ε) has to be added to ln(|a|) so the tiny g forces get translated to the ±base of the rectangles to be drawn. Which means
 * Clip a to ε...maxAbsoluteValue — (aʹ)
 * ln(aʹ) goes from ln(ε) ... ln(maxAbsoluteValue)
 * Add ln(ε) to ln(aʹ) — ln(εaʹ)
 * Scale so ln(maxAbsoluteValue) → 0.5˙ * outputSpan

 ACTUALLY… What am I trying to solve here? For sake of computation, we care only about |a|.
    OTOH, we sometimes care about negative G
          we care about saturating the bars.
    If we don't care about negatives, then ln(|a|) makes sense,
          but we have to chop off the bottom of the range.
 */

        return absoluteInput
    }
}

struct SimpleBarView: View {
    /// The breadth of the space between bars, as a fraction of the bar width
    let spaceFraction: CGFloat

    /// The width of the data bars in points.
    let barWidth: CGFloat
    /// The width of the empty spaces in points.
    let spaceWidth: CGFloat

    /// The data to be drawn. Must be non-negative.
    let data: [Double]
    /// The greatest value among the `data`.
    let maxValue: Double

    let barColor: Color

    init(_ points: [Double], spacing: CGFloat = 0.05, color: Color = .teal, reservedMax: CGFloat = 0) {
        self.data = points
        self.spaceFraction = spacing

        let dblBarCount = CGFloat(points.count)
        let denominator = dblBarCount + spacing * (dblBarCount-1)
        self.barWidth = 1.0 / denominator
        self.spaceWidth = spacing * barWidth

        let dataMaximum = data.max() ?? 0.0
        self.maxValue = (reservedMax > dataMaximum) ? reservedMax : dataMaximum

        barColor = color
    }

    /// A `Gradient` to draw behind the bars.
    private let backGradient = Gradient(colors: [
        Color(UIColor(white: 0.95, alpha: 1.0).cgColor),
        Color(UIColor(white: 0.80, alpha: 1.0).cgColor)
        ]
    )

    var body: some View {
        GeometryReader {
            proxy in
            ZStack(alignment: .bottom) {
                // Back: A vertical gradient
                Rectangle()
                    .fill (
                    .linearGradient(
                        backGradient,
                        startPoint: UnitPoint(x: 0.5, y: 0),
                        endPoint: UnitPoint(x: 0.5, y: 1))
                    )

                // Fore: One bar per datum, spaced per the
                //       spacing parameter of init.
                if data.isEmpty {
                    // Don't draw the bars if there's no data.
                    EmptyView()
                }
                else {
                    barsView(in: proxy.size)
                        .padding(
                            EdgeInsets(top: 5.0, leading: 0,
                                       bottom: 0, trailing: 0))
                    // See note after this method on padding anomaly
                }
            }
        }
    }

    /*
     NOTE
     I don't know why, but supplying a leading pad
     shifts the entire view, (background included?)
     to the trailing side.
     Trailing pad seems to make no difference.
     */

    func barsView(in size: CGSize) -> some View {
        HStack(alignment: .bottom,
               spacing: size.width*spaceWidth) {
            ForEach(data, id: \.self) { datum in
                Rectangle()
                    .frame(width:
                            barWidth * size.width,
                           height: size.height * datum/maxValue)
                    .foregroundColor(barColor)
                    .shadow(color: .gray,
                            radius: 2.0,
                            x: 0, y: 0)
                    .border(.black, width: 1)
            }
        }
    }
}

struct ThreeBarView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleData: [Double] = [2.0, 0.9, 0.4 ]//, 1.2]
        return SimpleBarView(sampleData, spacing: 0.4,
                             color: .accentColor
//                            , reservedMax: 3.0
        )
            .frame(width: .infinity, height: 160, alignment: .center)
            .padding()
            .previewInterfaceOrientation(.portrait)
    }
}
