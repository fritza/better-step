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
        VStack(alignment: .center, spacing: 20)
        {
            GeometryReader { proxy in
                Text(DASIQuestion.with(id: questionID).text)
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(width: proxy.size.width)
                    .fixedSize(horizontal: true, vertical: false)
            }
            Spacer(minLength: 20)

            // FIXME: No way to add a checkmark.
            YesNoView(["Yes", "No"]) {
                choice in
                self.thisAnswer = (choice.id == 0) ? .yes : .no
                self.report
                    .respondToQuestion(
                        self.questionID,
                        with: self.thisAnswer)
            }

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
        .padding()
    }
}

struct DASIQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        DASIQuestionView(id: 9)
            .padding()
            .environmentObject(DASIReport(forSubject: "ABCD"))
    }
}
