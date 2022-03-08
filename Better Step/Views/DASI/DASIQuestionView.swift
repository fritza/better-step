//
//  DASIQuestionView.swift
//  CardSeries
//
//  Created by Fritz Anderson on 3/4/22.
//

import SwiftUI

struct QuestionContentView: View {
    let content: String
    let index: Int
    var text: String {
        DASIQuestion.with(id: QuestionID(index: index)).text
    }
    var body: some View {
//        let template = DASIQuestion.with(id: QuestionID(index: index)
//        Text(content + " (\(index))")
        Text(self.text)
            .font(.title)
    }
}

struct DASIQuestionView: View {
    @EnvironmentObject var envt: DASIContentState
    @EnvironmentObject var reportContents: DASIReportContents
    @State var answerState: AnswerState

    func updateForNewBinding() {
        if let nextID = envt.questionID {
            self.answerState =
            reportContents
                .responseForQuestion(
                    id: nextID)
            print(#function, "exiting")
        }
        else { self.answerState = .unknown }
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

            if envt.selected.questionID == nil {
                // It turned out that incrementing or decrementing
                // the DASIContentState envt would still attempt to
                // put up the QuestionContentView for a page
                // that had no questionID.
                //
                // I'm not happy with this apparent hack.
                EmptyView()
            }
            else {
                Spacer()
                QuestionContentView(
                    content: "Do you have difficulty?",
                    index:
                        envt.selected.questionID!.index)
                    .padding()
                
                Spacer()
                YesNoStack(
                    boundState: self.$answerState,
                    completion: { state in
                        reportContents.didRespondToQuestion(
                            id: envt.questionID!, with: state)
                        envt.increment()
                        updateForNewBinding()
                    }
                )
                    .frame(height: 130)
                    .padding()

                Text("Bound value = \(self.answerState.description)")

                .navigationTitle(
                    "DASI - \((envt.questionID?.description ?? "Out of range"))"
                )
            }
        }
    }
}

struct DASIQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        DASIQuestionView(answerState: .yes)
            .environmentObject(DASIContentState(.presenting(question: 0.indexQID)))
            .environmentObject(DASIReportContents())
    }
}


