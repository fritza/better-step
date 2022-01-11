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
    func callToActionLink(buttonTitle: String,
                          linkLabel: String) -> some View
    {
        NavigationLink(destination: {
            DASIQuestionView(question: DASIQuestion.with(id: 1))
        }) {
            Text(buttonTitle)
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                GenericInstructionView(
                    bodyText: surveyNarrative, sfBadgeName: "checkmark.square")
                    .navigationTitle("DASI Survey")
                    .padding(32)

                callToActionLink(buttonTitle: "Proceed",
                                   linkLabel: "Proceed to Survey")
                Spacer()
            }
        }
    }
}

struct SurveyView_Previews: PreviewProvider {
    static var previews: some View {
        SurveyView()
    }
}
