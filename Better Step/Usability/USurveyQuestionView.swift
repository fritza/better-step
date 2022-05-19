//
//  USurveyQuestionView.swift
//  Better Step
//
//  Created by Fritz Anderson on 5/18/22.
//

import Foundation
import SwiftUI

// MARK: -
struct USurveyQuestionView: View {
    @EnvironmentObject var allResponses: SurveyResponses
    @State var score: Double
    let index: Int

    init(id: Int, score: Double) {
        self.index = id
        self.score = score
    }

    func transfer() {
        allResponses.respond(to: index, with: Int(score))
    }

    var body: some View {
        VStack {
            SurveyPromptView(
                index: index,
                prompt: USurveyQuestion.question(withID: index).text)
            Slider(value: $score, in: 1...7, step: 1) {
                Text("choose 1-7") }
        minimumValueLabel: { Text("1") }
        maximumValueLabel: { Text("7") }
        }
        .navigationTitle("Survey")
    }
}

struct USurveyQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VStack {
                Spacer()
            USurveyQuestionView(id: 3, score: 3.0)
                .environmentObject(SurveyResponses())
                .padding()
            Spacer()
            }
        }
    }
}
