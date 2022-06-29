//
//  SimpleBarView.swift
//  Async Accel
//
//  Created by Fritz Anderson on 3/10/22.
//

import SwiftUI

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

    /// Create a `SimpleBarView`, a bar chart for an array of `Double` values.
    ///
    /// The maximum value displayed at any one time is the maximum value among the data `points`: `[1, 3, 2] → [1/3, 1, 2/3]`, However, if all elements are smaller than `reservedMax`, they will be scaled to that value: `[1, 3, 2], max 5 → [1/5, 3/5, 2/5]`.
    /// - Parameters:
    ///   - points: An array of `Double` values that determine the height of the bars
    ///   - spacing: The amount of space between bars, as a fraction of the bars themselves. Default 5%
    ///   - color: The color fill for the bars. Default is `.teal`.
    ///   - reservedMax: The minimum vertical scale to use, regardless of how small the data are. Default is `0.01` (the tallest of the three bars determines the scale moment-to-moment). Non-zero to prevent division by zero.
    init(_ points: [Double],
         spacing: CGFloat = 0.05,
         color: Color = .teal,
         reservedMax: CGFloat = 0.01) {
        precondition(reservedMax > 0.0)

        self.data = points
        self.spaceFraction = spacing

        let dblBarCount = CGFloat(points.count)
        let denominator = dblBarCount + spacing * (dblBarCount-1)
        self.barWidth = 1.0 / denominator
        self.spaceWidth = spacing * barWidth

        self.maxValue = Swift.max(
            (data.max() ?? -.infinity),
            reservedMax)

        barColor = color
    }

    /// A `Gradient` to draw behind the bars.
    private let backGradient = Gradient(colors: [
        Color(UIColor(white: 0.95, alpha: 1.0).cgColor),
        Color(UIColor(white: 0.80, alpha: 1.0).cgColor)
        ]
    )

    var gradientBackground: some View {
        Rectangle()
            .fill (
            .linearGradient(
                backGradient,
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 1))
            )
    }

    func bar(for datum: CGFloat, in size: CGSize) ->  some View {
        return Rectangle()
            .frame(width : barWidth * size.width       ,
                   height: size.height * datum/maxValue)
            .foregroundColor(barColor)
    }

    var body: some View {
        GeometryReader {
            proxy in
            ZStack(alignment: .bottom) {
                gradientBackground

                // Fore: One bar per datum, spaced per the
                //       spacing parameter of init.
                if data.isEmpty {
                    // Don't draw the bars if there's no data.
                    EmptyView()
                }
                else {
                    HStack(alignment: .bottom,
                           spacing: proxy.size.width*spaceWidth) {
                        ForEach(data, id: \.self) { datum in
                            bar(for: datum, in: proxy.size)
                        }
                    }
                    .padding(EdgeInsets(top: 5.0, leading: 0, bottom: 0, trailing: 0))
                }
            }
        }
    }
}

struct ThreeBarView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleData: [Double] = [2.0, 0.9, 0.4 ]//, 1.2]
        return SimpleBarView(
            sampleData,
            spacing: 0.4,
            color: .green // .accentColor
//                            , reservedMax: 3.0
        )
            .frame(width: .infinity, height: 160, alignment: .center)
            .padding()
            .previewInterfaceOrientation(.portrait)
    }
}
