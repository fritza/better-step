//
//  UsabilityInterstitialView.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/12/22.
//

import SwiftUI

private let entryContent     = try! CardContent.contentArray(from: ["usability-intro"         ])
private let endingContent    = try! CardContent.contentArray(from: ["usability-ending"        ])


extension Image {
    func scaledAndTinted() -> some View {
        self.resizable()
            .scaledToFit()
            .foregroundColor(.accentColor)
            .symbolRenderingMode(.hierarchical)
    }
}

// TODO: Remove UsabilityInterstitialView.

// FIXME: All these interstitial views are getting redundant.

#warning("Replace or derive UsabilityInterstitialView with the simple cards.")

/// This is mostly redundant of `DASIInterstitialView`, except that one is a DASI depencency, and it doesn't do the right thing about the toolbar.
///
/// Its ``SuccessValue`` as a ``ReportingPhase`` is `Void`.
struct UsabilityInterstitialView: View, ReportingPhase {
    enum UsabilityInterstitials { case entry, ending
        var content: [CardContent] {
            switch self {
            case .ending: return endingContent
            case .entry:  return entryContent
            }
        }
    }

    typealias SuccessValue = UsabilityInterstitials
    let completion: ClosureType // Void value type.
    let cardSpecs: [CardContent]
    let whichPhase: UsabilityInterstitials

    init(cardPhase: UsabilityInterstitials,
         completion: @escaping ClosureType) {
        self.whichPhase = cardPhase
        cardSpecs = cardPhase.content
        self.completion = completion
    }

    var body: some View {
        InterCarousel(content: cardSpecs) {
            completion(
                .success(whichPhase)
            )
        }
        .padding()
    }


    @State var showNotIntegratelert = false

    // TODO: Turn these into a Decodable struct.
    /*
     let titleText: String
     let bodyText: String
     let systemImageName: String
     let continueTitle: String
    var body: some View {
        VStack {
            Text(titleText).font(.largeTitle)
            Spacer()
            HStack {
                Spacer()
                Image(systemName: systemImageName)
                    .scaledAndTinted()
                    .frame(width: 200)
                //                    .symbolRenderingMode(.hierarchical)
                Spacer()
            }
            .accessibilityLabel("icon")
            Spacer()
            Text(bodyText)
                .font(.body)
                .accessibilityLabel("descriptive text")
                .minimumScaleFactor(0.5)
            
            Spacer()
            // So far near-identical to DASIInterstitialView
            // (ignoring the ugliness around the toolbar)
            
            Button(continueTitle) {
                completion(.success(()))
            }
            .accessibilityLabel("continuation button")
        }
        
        // FIXME: End-of-phase should be the top container
        //        Not an inert farewell.
        
        .alert("No destination beyond Usability", isPresented: $showNotIntegratedAlert, actions: { },
               message: {
            Text("The G Bars app doesn't integrate the phases of Step Test. You’ve gone as far as you can with Usability.")
        })
        .padding()
        .toolbar(.hidden)
    }
*/

}

private let viewTitle = "Usability"
let usabilityInCopy = """
In this part of the session, we’d like to hear from you on how easy this app was to use, so we can improve future versions.

You will be asked for you view of \(UsabilityQuestion.count.spelled) features of the app, responding from 1 (dissatisfied) to 7 (very satisfied).

You must complete this survey before going on with the app, but you will be asked to complete it only once.
"""

let usabilityOutCopy = """
Thank you for your feedback.

Use the Back button if you want to review your answers. You will not be able to revise your answers after you tap Continue.
"""

private let systemImageName = "person.crop.circle.badge.questionmark"
struct UsabilityInterstitialView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UsabilityInterstitialView(cardPhase: .entry, completion: {
                result in
                let endpoint = try! result.get()
                print(#function, "Would pass up to container:", endpoint)
            })
        }

        NavigationView {
            UsabilityInterstitialView(cardPhase: .ending, completion: {
                result in
                let endpoint = try! result.get()
                print(#function, "Would pass up to container:", endpoint)
            })
        }
            /*
            ZStack {
                UsabilityInterstitialView(
                    titleText: viewTitle,
                    bodyText: usabilityInCopy,
                    systemImageName: systemImageName,
                    continueTitle: "Continue") {
                        str in
                        print(str)
                    }
            }
             */
    }
}
