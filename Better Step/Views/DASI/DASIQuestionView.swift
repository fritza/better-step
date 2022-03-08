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
    // FIXME: Verify that the report contents don't go away
    // before it's time to report.
    var body: some View {
        VStack {
            ForwardBackBar(forward: envt.selected < DASIStages.maxPresenting,
                           back: envt.selected > DASIStages.minPresenting,
                           action: { goingForward in
                if goingForward {
                    envt.increment()
                }
                else {
                    envt.decrement()
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
                    content: "Do you have difficulty rogering, filberting, and professional disportment?",
                    index:
                        envt.selected.questionID!.index)
                    .padding()

                Spacer()
                Button("-> Next Category") {
                    envt.selected.advance()
//                    envt.selected = envt.selected.advance()
                    //                envt.selected = envt.selected?.next
                }
                Spacer()
                YesNoStack(selectedButtonID: 1) {
                    answer in
                    // Record the response
                    reportContents.didRespondToQuestion(
                        id: envt.selected.questionID!,
                        with: answer)
                    envt.increment()
                }
                .frame(height: 130)
                .padding()
                .navigationTitle(
                    "DASI - \((envt.questionID?.description ?? "Out of range"))"
                )
            }
        }
    }
}

struct DASIQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        DASIQuestionView()
            .environmentObject(DASIContentState(.presenting(question: 0.indexQID)))
    }
}


