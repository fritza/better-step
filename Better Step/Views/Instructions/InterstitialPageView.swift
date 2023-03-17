//
//  InterstitialPageView.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/10/22.
//

import SwiftUI

// MARK: - Rendering

enum Rendering {
    static let bodyFont = Font.title2
    static let textMinScale: CGFloat = 0.5
    
    enum SizeLimit {
        case height(CGFloat)
        case width( CGFloat)
    }
    
    static let fontDimension: CGFloat = 200
    static let iconLimit = SizeLimit.height(fontDimension)
}


// MARK: - InterstitialPageView

// TODO: Replace GenericInstructionView with this.
//       which DOES NOT have contentAbove and contentBelow


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
                Text(pageTitle)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .tag("title_text")
                Spacer()
            }
            // MARK: Instructional text
            if let contentAbove = item.contentAbove {
                Text(contentAbove)
                    .font(Rendering.bodyFont)
                    .minimumScaleFactor(Rendering.textMinScale)
                Spacer(minLength: 30)
            }
            // MARK: SF Symbol
            Image(systemName: item.systemImage ?? "bolt.slash.fill")
                .scaledAndTinted()
                .frame(height: 200)
            Spacer()
            if let contentBelow = item.contentBelow {
                Text(contentBelow)
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
        contentAbove: "You will now be asked to perform two walks of two minutes each.||• The first at a normal walking pace|• The second as fast as you can safely walk",
        systemImage: "figure.walk",
        contentBelow: "Tap “Comtinue” when you are done.",
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
