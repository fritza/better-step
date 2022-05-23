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
            .minimumScaleFactor(0.5)
    }
}

struct DASIQuestionView: View {
    @EnvironmentObject var envt: DASIPages
    @EnvironmentObject var reportContents: DASIResponseList
    @State var answerState: AnswerState

    func updateForNewBinding() {
        let answerState: AnswerState
        if let qID = envt.questionIdentifier,
           let state = reportContents
            .responseForQuestion(identifier: qID) {
            answerState = state
        }
        else {
            answerState = .unknown
        }
        self.answerState = answerState
    }

    // FIXME: Verify that the report contents don't go away
    // before it's time to report.
    var body: some View {
        VStack {
            if envt.questionIdentifier != nil {
                QuestionContentView(
                    content: "Do you have difficulty?",
                    questionIndex:
                        envt.questionIdentifier!)
                .padding()

                Spacer()
                YesNoStack(
                    boundState: self.$answerState,
                    completion: { state in
#warning("How many times do we do this?")
                        guard let qID = envt.questionIdentifier else {
                            return
                        }
                        reportContents
                            .didRespondToQuestion(
                                id: qID,
                                with: state)
                        envt.increment()
                        updateForNewBinding()
                    }
                )
                .frame(height: 130)
                .padding()
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button("← Back") {
                    envt.decrement()
                    updateForNewBinding()
                }
                .disabled(envt.selected <= DASIStages.minPresenting)
                gearBarItem()
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Next →") {
                    envt.increment()
                    updateForNewBinding()
                }
                .disabled(envt.selected >= DASIStages.maxPresenting)
            }
        }
        .navigationTitle(
            "Question \(envt.questionIdentifier?.description ?? "NO ID"):"
        )
    }
}

struct DASIQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DASIQuestionView(answerState: .yes)
        }
        .environmentObject(DASIPages(.presenting(questionID: 2)))
        .environmentObject(DASIResponseList())
    }
}


