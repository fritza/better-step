//
//  SurveyView.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/19/21.
//

import SwiftUI

let surveyNarrativeString = """
This exercise will assess your stride and pace though a short (six-minute) walk. An alarm sound to signal the beginning and the end of the exercise.

Tap “Proceed" when you are ready
"""

struct SurveyView: View {
    private let imageScale: CGFloat = 0.6
    @State private  var isProceeding = false

    var body: some View {
        GenericInstructionView(titleText: "DASI Survey",
                               bodyText: surveyNarrativeString, sfBadgeName: "checkmark.square",
        proceedTitle: "Go ahead on") {

        }
        .padding(32)
    }
}

struct SurveyView_Previews: PreviewProvider {
    static var previews: some View {
        SurveyView()
    }
}
