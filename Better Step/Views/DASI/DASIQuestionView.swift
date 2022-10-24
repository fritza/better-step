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
    @EnvironmentObject var pageSelection : DASIPageSelection
    @EnvironmentObject var reportContents: DASIResponseList
    @State var answerState: AnswerState

    func updateForNewBinding() {
        let answerState: AnswerState
        if let qID = pageSelection.questionIdentifier,
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
            if pageSelection.questionIdentifier != nil {
                QuestionContentView(
                    content: "Do you have difficulty?",
                    questionIndex:
                        pageSelection.questionIdentifier!)
                .padding()

                Spacer()
                YesNoStack(
                    answer: reportContents.responseForQuestion(identifier: pageSelection.questionIdentifier!)!,
                    completion: { state in
                        guard let answer = try? state.get() else {
                            print(#function, "- got an error answer.")
                            return
                        }
                        reportContents
                            .didRespondToQuestion(
                                id: pageSelection.questionIdentifier!,
                                with: answer)
                        pageSelection.increment()
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
                    pageSelection.decrement()
                    updateForNewBinding()
                }
                .disabled(pageSelection.selected <= DASIStages.minPresenting)
            }
// TODO: Replace with ToolbarItem
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                gearBarItem()
                Button("Next →") {
                    pageSelection.increment()
                    updateForNewBinding()
                }
                .disabled(pageSelection.selected >= DASIStages.maxPresenting)
            }
        }
        .navigationTitle(
            "Question \(pageSelection.questionIdentifier?.description ?? "NO ID"):"
        )
    }
}

struct DASIQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DASIQuestionView(answerState: .yes)
        }
        .environmentObject(DASIPageSelection(.presenting(questionID: 1)))
        .environmentObject(DASIResponseList())
    }
}


