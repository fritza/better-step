//
//  InterstitialPageView.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/10/22.
//

import SwiftUI

// MARK: - InterstitialPageView

// TODO: Replace GenericInstructionView with this.
//       which DOES NOT have introAbove and introBelow

#warning("Replace GenericInstructionView")


/// A `View` that presents a single page derived from ``InterstitialInfo``:  text, SF Symbols name, Action button; plus a callback when the action button is tapped.
struct InterstitialPageView: View {
    let item: InterstitialInfo
    let proceedCallback: () -> Void

    /// Initialize the view given the content information and a button-action closure
    /// - Parameters:
    ///   - info: An ``InterstitialInfo`` specifying text and symbol content.
    ///   - callback: A closure to be called when the action button (**Next**, **Continue**, etc.) is tapped.
    init(info: InterstitialInfo,
         proceedCallback callback: @escaping () -> Void) {
        item = info
        self.proceedCallback = callback
    }

    // MARK: - body
    var body: some View {
        VStack {
            // MARK: Instructional text
            Text(item.introAbove)
                .font(.body)
                .minimumScaleFactor(0.75)
            Spacer(minLength: 30)
            // MARK: SF Symbol
            Image(systemName: item.systemImage ?? "bolt.slash.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.accentColor)
                .frame(height: 200)
                .symbolRenderingMode(.hierarchical)
            Spacer()
            Text(item.introBelow)
                .font(.body)
                .minimumScaleFactor(0.75)
            Spacer()

            // MARK: The action button
            Button(item.proceedTitle, action: proceedCallback)
        }
        .padding()
        .navigationTitle(item.pageTitle)
    }
}

// MARK: - Preview
struct InterstitialPageView_Previews: PreviewProvider {
    static let sampleIInfo = InterstitialInfo(id: 3, introAbove: "This is the instructional text.\nIt may be very long.", introBelow: "", proceedTitle: "Continue", pageTitle: "Exercise with a longer top.", systemImage: "figure.walk")

    static var previews: some View {
        NavigationView {
        InterstitialPageView(
            info: sampleIInfo,
        proceedCallback: { print("beep") })
        .padding()
        }
    }
}
