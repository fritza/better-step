//
//  DASIQuestionView.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/28/21.
//

import SwiftUI

struct DASIQuestionView: View {
    static let yesNoWidth: CGFloat = 80

    @EnvironmentObject var report: DASIReport
    @State var questionID: Int
    @State var thisAnswer: AnswerState
    // How do we sync it with the report?

    var yesLabel: Label<Text, Image> {
        Label("Yes", systemImage:
                (report.responseForQuestion(id: questionID) == .yes) ?
              "checkmark" : "")
    }

    var noLabel: Label<Text, Image> {
        Label("No", systemImage:
                (report.responseForQuestion(id: questionID) == .no) ?
              "checkmark" : "")
    }

    init(id: Int) {
        self.questionID = id
        self.thisAnswer = .unknown
        // FIXME: Get the actual, current report value.
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Text(DASIQuestion.with(id: questionID).text)
                .font(.title)
                .fontWeight(.semibold)
            Spacer(minLength: 40)

            // TODO: A Yes/No view.
            Button {
                thisAnswer = .yes
                report.respondToQuestion(questionID, with: .yes)
            } label: {
                HStack {
                    if (thisAnswer == .yes) {
                        Image(systemName: "checkmark")
                    }
                    Spacer()
                    Text("Yes")
                }
                .font(.title2)
                .frame(width: Self.yesNoWidth)
            }
            Button {
                thisAnswer = .no
                report.respondToQuestion(questionID, with: .no)
            } label: {
                HStack {
                    if (thisAnswer == .no) {
                        Image(systemName: "checkmark")
                    }
                    Spacer()
                    Text("No")
                }
                .font(.title2)
                .frame(width: Self.yesNoWidth)
            }
            Spacer()

            HStack {
                Button {
                    if questionID > 0 {
                        questionID -= 1
                        thisAnswer = report.responseForQuestion(id: questionID)
//                        thisAnswer = .unknown
                    }
                } label: { Text("Back") }
                Spacer()
                Button {
                    if questionID < 11 {
                        questionID += 1
                        thisAnswer = report.responseForQuestion(id: questionID)
//                        thisAnswer = .unknown
                    }
                } label: { Text("Next") }
            }

        }
    }
}

struct DASIQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        DASIQuestionView(id: 3)
            .padding()
            .environmentObject(DASIReport(forSubject: "ABCD"))
    }
}
