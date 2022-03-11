//
//  SimpleBarView.swift
//  Async Accel
//
//  Created by Fritz Anderson on 3/10/22.
//

import SwiftUI

extension Collection {
    func interleave(with separator: Element) -> [Element] {
        guard count > 1 else { return Array(self) }
        var retval = zip(self, Array(repeating: separator, count: self.count))
            .map { [$0, $1] }
            .flatMap { $0 }
        retval = retval.dropLast()
        return retval
    }
}


struct SimpleBarView: View {
    static let barProportion  : CGFloat = 0.28
    let spaceFraction: CGFloat
    let barCount: Int

    let barWidth: CGFloat
    let spaceWidth: CGFloat

    let verticalScale: CGFloat = 1.0

    let data: [Double]
    let maxValue: Double

    init(_ points: [Double], spacing: CGFloat = 0.05) {
        self.data = points
        self.barCount = points.count
        self.spaceFraction = spacing

        let dblBarCount = CGFloat(points.count)
        let denominator = dblBarCount + spacing * (dblBarCount-1)
        self.barWidth = 1.0 / denominator
        self.spaceWidth = spacing * barWidth

        self.maxValue = data.max() ?? 0.0
    }

    func widths(_ proxy: GeometryProxy) -> [CGFloat] {
        let dblBarCount = CGFloat(barCount)
        let denominator = dblBarCount + spaceFraction * (dblBarCount-1)
        let barWidth = 1.0 / denominator
        let proportionArray = [CGFloat](repeating: barWidth, count: barCount)
            .interleave(with: barWidth * spaceFraction)
            .map { $0 * proxy.size.width }
        return proportionArray
    }

    let backGradient = Gradient(colors: [
        Color(UIColor(white: 0.95, alpha: 1.0).cgColor),
        Color(UIColor(white: 0.8, alpha: 1.0).cgColor)
        ]
    )

    var body: some View {
        GeometryReader {
            proxy in
            ZStack {
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
                HStack(alignment: .bottom, spacing: proxy.size.width*spaceWidth) {
                    ForEach(0..<data.count) { index in
                        Rectangle()
                            .frame(width: barWidth * proxy.size.width,
                                   height: proxy.size.height * data[index]/maxValue)
                            .foregroundColor(Color.red)
                            .shadow(color: .gray, radius: 4.0,
                                    x:  2.0, y: 0)
                    }
                }
            }
        }
    }
}

struct ThreeBarView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleBarView([2.0, 0.9, 0.4, 1.2], spacing: 0.4)
            .frame(width: .infinity, height: 160, alignment: .bottom)
            .padding()
.previewInterfaceOrientation(.portrait)
    }
}
