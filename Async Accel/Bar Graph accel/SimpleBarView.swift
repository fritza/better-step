//
//  SimpleBarView.swift
//  Async Accel
//
//  Created by Fritz Anderson on 3/10/22.
//

import SwiftUI

// MARK: - SimpleBarView
struct SimpleBarView: View {
    // MARK: - Properties
    /// The breadth of the space between bars, as a fraction of the bar width
    let spaceFraction: CGFloat

    /// The width of the data bars in points.
    let barWidth: CGFloat
    /// The width of the empty spaces in points.
    let spaceWidth: CGFloat

    /// The data to be drawn. All vaues must be non-negative.
    let data: [Double]
    /// The greatest value among the `data`.
    let maxValue: Double

    let barColor: Color

    // MARK: - Initialization

    /// Initialize the view, including the represented data.
    ///
    /// Layout and display depend on the length of the data `Array`; varying the count would render as expected. ATW that's not needed.
    ///
    /// `reservedMax` and `maxValue` represent the greatest value the view will display; anything greater is clipped to the top of the view. Callers are advised to set this value; otherwise it defaults to the maximum of `points`, which would rescale the entire graph at each tick of the data clock.
    /// - Parameters:
    ///   - points: The data to be represented. If empty, no bars will be displayed.
    ///   - spacing: The horizontal inset for each bar, as a fraction of the bar's share of the stack. Default `0.05`.
    ///   - color: The color of the bars. Default `.teal`. Callers are advised to find something else, because teal is disgusting.
    ///   - reservedMax: The maximum value the view will represent; any greater value will be clipped to the top of the view.  Defaults to `0`, which rescales the vertical axis rather than clipping it.
    init(_ points: [Double], spacing: CGFloat = 0.05,
         color: Color = .teal, reservedMax: CGFloat = 0) {
        (barColor, data, spaceFraction) = (color, points, spacing)

        let dblBarCount = CGFloat(points.count)
        let dataMaximum = points.max() ?? 0.0
        self.maxValue = (reservedMax > dataMaximum) ? reservedMax : dataMaximum

        if points.isEmpty {
            // Prevent a division-by-zero (no bars)
            self.barWidth = 0.0
            self.spaceWidth = 0.0
        }
        else {
            let denominator = dblBarCount + spacing * (dblBarCount-1)
            self.barWidth = 1.0 / denominator
            self.spaceWidth = spacing * barWidth
        }
    }

    /// A `Gradient` to draw behind the bars.
    private let backGradient = Gradient(colors: [
        Color(UIColor(white: 0.95, alpha: 1.0).cgColor),
        Color(UIColor(white: 0.80, alpha: 1.0).cgColor)
        ]
    )

    // MARK: - Views
    /// `View` protocol adoption.
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

    /// A horizontal visual array of the values in `data`.
    ///
    /// Depends on
    ///
    /// - `self.barColor` (into `init(_:spacing:color:reservedMax:)`)
    /// - `self.spaceWidth` (constant)
    /// - `self.barWidth` (constant set in `init`)
    /// - Parameter size: The size of the `SimpleBarView`, as determined by `GeometryReader`.
    /// - Returns: An `HStack` of `Rectangle`s whose height represents `data` relative to the known (or reserved) maximum value.
    private func barsView(in size: CGSize) -> some View {
        HStack(alignment: .bottom,
               spacing: size.width*spaceWidth) {
            ForEach(data, id: \.self) { datum in
                Rectangle()
                    .frame(width : barWidth * size.width,
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
