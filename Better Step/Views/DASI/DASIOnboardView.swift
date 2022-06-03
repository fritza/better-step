//
//  DASIOnboardView.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/7/22.
//

import SwiftUI

#warning("Replace with a generalized InterstitialView, or add an Interstitial protocol")
/// Present an explanation and instructions for the DASI process. DASI can be done only once (if the CD store on `DASIResponses` is full).
struct DASIOnboardView: View {
static let instructions = """
In this part of the assessment, you will be asked \(DASIQuestion.count) questions about how well you do with various activities.

Answer “Yes” or “No” to each. You will be able to move backward and forward through the questions, but you must respond to all for this exercise to be complete.
"""

    @EnvironmentObject var envt: DASIPages
    @State var shouldShow = false

    // TODO: Add the forward/back bar.

    var body: some View {
        VStack {
            Spacer()
            GenericInstructionView(
                titleText: "Activity Survey",
                bodyText: Self.instructions,
                sfBadgeName: "checkmark.square",
                proceedTitle: "Continue") {
                    envt.increment()
                }
                .padding()
                .navigationBarHidden(true)
        }
        .onAppear{
        }
    }
}

struct DASIOnboardView_Previews: PreviewProvider {
    static var previews: some View {
        DASIOnboardView()
            .environmentObject(DASIPages(.landing))
    }
}
