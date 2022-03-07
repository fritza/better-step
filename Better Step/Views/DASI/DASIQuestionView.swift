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
//        Text(c ontent + " (\(index))")
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
            HStack {
                if envt.pageNum > 0 {
                    Button("\(Image(systemName: "arrow.left")) Previous") {
                        envt.pageNum -= 1
                    }
                }
                Spacer()
                if envt.pageNum < DASIQuestion.count-1 {
                    Button("Next \(Image(systemName: "arrow.right"))") {
                        envt.pageNum += 1
                    }
                }
            }
            .padding()

            Spacer()
            QuestionContentView(content: "Do you have difficulty rogering, filberting, and professional disportment?", index: envt.pageNum)
                .padding()

            Spacer()
//            Text("Page: \(envt.pageNum)")
//                .font(.largeTitle)
//                .padding()
            Button("-> Next Category") {
                envt.selected = envt.selected?.next
            }
            Spacer()
            YesNoStack(selectedButtonID: 1) {
                answer in
                // Record the response
                reportContents.didRespondToQuestion(
                    id: envt.pageNum.qid,
                    with: answer)
                    envt.pageNum += 1
                    }
                        .frame(height: 130)
                        .padding()
        }
        .navigationTitle("DASI - \((envt.pageNum+1).description)")
    }
}

struct DASIQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        DASIQuestionView()
            .environmentObject(DASIContentState(.questions))
    }
}


