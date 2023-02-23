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


/// A `View` that presents a single page derived from ``InterstitialInfo``:  text, SF Symbols name, Action button; plus a callback when the action button is tapped.
struct InterstitialPageView: View, Identifiable {
    let item: InterstitialInfo
    let proceedCallback: () -> Void
    
    let id: Int
    
    /// Initialize the view given the content information and a button-action closure
    /// - Parameters:
    ///   - info: An ``InterstitialInfo`` specifying text and symbol content.
    ///   - callback: A closure to be called when the action button (**Next**, **Continue**, etc.) is tapped.
    init(info: InterstitialInfo,
         proceedCallback callback: @escaping () -> Void) {
        item = info
        self.proceedCallback = callback
        id = info.id
    }
    
    // MARK: - body
    var body: some View {
        VStack {
            if let pageTitle = item.pageTitle {
                Text("IPageView: " + pageTitle)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .tag("title_text")
                Spacer()
            }
            // MARK: Instructional text
            if let introAbove = item.introAbove {
                Text(introAbove)
                    .font(Rendering.bodyFont)
                    .minimumScaleFactor(Rendering.textMinScale)
                Spacer(minLength: 30)
            }
            // MARK: SF Symbol
            Image(systemName: item.systemImage ?? "bolt.slash.fill")
                .scaledAndTinted()
                .frame(height: 200)
            Spacer()
            if let introBelow = item.introBelow {
                Text(introBelow)
                    .font(.title3)
                    .minimumScaleFactor(0.75)
                Spacer()
            }
            
            // MARK: The action button
            if let proceedTitle = item.proceedTitle {
                Button(proceedTitle,
                       action: proceedCallback)
                Spacer()
            }
        }
        .padding()
        //        .navigationTitle(item.pageTitle)
    }
}

// MARK: - Preview
struct InterstitialPageView_Previews: PreviewProvider {
    static let sampleIInfo = InterstitialInfo(
        id: 1,
        pageTitle: "Walk Exercises",
        introAbove: "You will now be asked to perform two walks of two minutes each.||• The first at a normal walking pace|• The second as fast as you can safely walk",
        systemImage: "figure.walk",
        introBelow: "Tap “Comtinue” when you are done.",
        proceedTitle: "Continue")
    
    static var previews: some View {
        NavigationView {
            InterstitialPageView(
                info: sampleIInfo,
                proceedCallback: { print("beep") })
            .padding()
        }
    }
}
