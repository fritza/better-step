//
//  DASIQuestionView.swift
//  CardSeries
//
//  Created by Fritz Anderson on 3/4/22.
//

import SwiftUI

struct QuestionContentView: View {
    let content: String
    let questionIndex: Int
    var text: String {
        DASIQuestion
            .with(id: questionIndex).text
    }
    var body: some View {
        Text(self.text)
            .font(.title)
    }
}

struct DASIQuestionView: View {
    @EnvironmentObject var envt: DASIContentState
    @EnvironmentObject var reportContents: DASIReportContents
    @State var answerState: AnswerState

    func updateForNewBinding() {
        let answerState: AnswerState
        if let state = reportContents
            .responseForQuestion(identifier: envt.questionIdentifier) {
            answerState = state
        }
        else { answerState = .unknown }
        self.answerState = answerState
    }

    // FIXME: Verify that the report contents don't go away
    // before it's time to report.
    var body: some View {
        VStack {
            ForwardBackBar(forward: envt.selected < DASIStages.maxPresenting,
                           back: envt.selected > DASIStages.minPresenting,
                           action: { goingForward in
                if goingForward {
                    envt.increment()
                    updateForNewBinding()
                }
                else {
                    envt.decrement()
                    updateForNewBinding()
                }
            })
                .frame(height: 44)
                .padding()
            Spacer()
            QuestionContentView(
                content: "Do you have difficulty?",
                questionIndex:
                    envt.selected.questionIdentifier!)
                .padding()

            Spacer()
            YesNoStack(
                boundState: self.$answerState,
                completion: { state in
                    reportContents
                        .didRespondToQuestion(
                            id: envt.questionIdentifier,
                            with: state)
                    envt.increment()
                    updateForNewBinding()
                }
            )
                .frame(height: 130)
                .padding()

            Text("Bound value = \(self.answerState.description)")

                .navigationTitle(
                    "DASI - \(envt.questionIdentifier.description)"
                )
        }
    }
}

struct DASIQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        DASIQuestionView(answerState: .yes)
            .environmentObject(DASIContentState(.presenting(questionID: 0)))
            .environmentObject(DASIReportContents())
    }
}


