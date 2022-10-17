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
    @EnvironmentObject var envt: DASIPageSelection
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
                    answer: reportContents.responseForQuestion(identifier: envt.questionIdentifier!)!,
                    completion: { state in
                        guard let answer = try? state.get() else {
                            print(#function, "- got an error answer.")
                            return
                        }
                        reportContents
                            .didRespondToQuestion(
                                id: envt.questionIdentifier!,
                                with: answer)
                        envt.increment()
                        updateForNewBinding()
                    }
                )
                .frame(height: 130)
                .padding()
            }
        }
        .toolbar {
// TODO: Replace with ToolbarItem
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button("← Back") {
                    envt.decrement()
                    updateForNewBinding()
                }
                .disabled(envt.selected <= DASIStages.minPresenting)
            }
// TODO: Replace with ToolbarItem
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                gearBarItem()
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
        .environmentObject(DASIPageSelection(.presenting(questionID: 2)))
        .environmentObject(DASIResponseList())
    }
}


