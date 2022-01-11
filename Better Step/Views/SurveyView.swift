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
        NavigationView {
            VStack {
                GenericInstructionView(
                    bodyText: surveyNarrative, sfBadgeName: "checkmark.square")
                    .navigationTitle("DASI Survey")
                    .padding(32)
                Button("Proceed!") {
                    NavigationLink("Proceed", destination: {
                        DASIQuestionView(question: DASIQuestion.with(id: 1))
                    })
                }
            }
        }
    }
}

struct SurveyView_Previews: PreviewProvider {
    static var previews: some View {
        SurveyView()
    }
}
