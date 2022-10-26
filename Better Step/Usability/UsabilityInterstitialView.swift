//
//  UsabilityInterstitialView.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/12/22.
//

import SwiftUI

// FIXME: All the interstitial views are getting redundant.

/// This is mostly redundant of `DASIInterstitialView`, except that one is a DASI depencency, and it doesn't do the right thing about the toolbar.
struct UsabilityInterstitialView: View, ReportingPhase {
    typealias SuccessValue = Void

    @State var showNotIntegratedAlert = false

    // TODO: Turn these into a Decodable struct.
    let titleText: String
    let bodyText: String
    let systemImageName: String
    let continueTitle: String
    let completion: ClosureType // Void value type.

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Image(systemName: systemImageName)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.accentColor)
                    .frame(width: 200)
                    .symbolRenderingMode(.hierarchical)
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
                #warning("increment in interstitial")
//                if pageSelection.canIncrement { pageSelection.increment()
//                }
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
        .navigationBarBackButtonHidden(true)
        .navigationTitle(titleText)
    }
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
private let continueTitle = "Continue"

struct UsabilityInterstitialView_Previews: PreviewProvider {
    /*
     let titleText: String
     let bodyText: String
     let systemImageName: String
     let continueTitle: String
     */
    static var previews: some View {
        NavigationView {
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
        }
    }
}
