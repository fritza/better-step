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
                    HStack(alignment: .bottom, spacing: proxy.size.width*spaceWidth) {
                        // TODO: Find another ForEach
                        ForEach(0..<data.count) { index in
                            Rectangle()
                                .frame(width:
                                        barWidth * proxy.size.width,
                                       height: proxy.size.height * data[index]/maxValue)
//                                .foregroundColor(Color.teal)
                                .foregroundColor(barColor)
                                .shadow(color: .gray,
                                        radius: 4.0,
                                        x: 0, y: 0)
                        }
                    }
                    .padding(EdgeInsets(top: 5.0, leading: 0, bottom: 0, trailing: 0))
                    // I don't know why, but supplying
                    // a leading pad shifts the entire view,
                    // (background included?) to the trailing
                    // side.
                    // Trailing pad seems to make no difference.
                }
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
