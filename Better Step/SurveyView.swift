//
//  SurveyView.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/19/21.
//

import SwiftUI

let surveyNarrative = """
This exercise asks you to respond to questions from a standard assessment of how free you are in your daily life.
"""

struct SurveyView: View {
    var body: some View {
        GenericInstructionView(titleText: "DASI Survey",
                               bodyText: surveyNarrative, sfBadgeName: "checkmark.square",
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
