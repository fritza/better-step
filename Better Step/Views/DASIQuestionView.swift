//
//  DASIQuestionView.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/28/21.
//

import SwiftUI

struct DASIQuestionView: View {
    static let yesNoWidth: CGFloat = 80

//    @Binding var report: DASIReport
//    @State private var thisAnswer: AnswerState

    // Remember question.id starts from 1
    private var thisAnswer: AnswerState {
        report.responseForQuestion(id: thisQuestion.id)
    }

    @State private var thisQuestion: DASIQuestion
    @EnvironmentObject var myDocument: DASIReportDocument
    var report: DASIReport { myDocument.report }
    private var questionID: Int { thisQuestion.id }

    private func recordAnswer(as newAnswer: AnswerState) {
        report.didRespondToQuestion(
            id: thisQuestion.id,
            with: newAnswer)
    }
    // How do we sync it with the report?

    var yesLabel: Label<Text, Image> {
        // Question IDs are one-based.
        // resopnseForQuestion takes a one-based ID
        Label("Yes", systemImage:
                (report.responseForQuestion(id: questionID) == .yes) ?
              "checkmark" : "")
    }

    var noLabel: Label<Text, Image> {
        // Question IDs are one-based.
        // resopnseForQuestion takes a one-based ID
        Label("No", systemImage:
                (report.responseForQuestion(id: questionID) == .no) ?
              "checkmark" : "")
    }

    init(question: DASIQuestion) {
        self.thisQuestion = question
//        thisAnswer = report.responseForQuestion(id: question.id)
    }

    func prepareForQuestion(_ newCurrentQuestion: DASIQuestion) {
        thisQuestion = newCurrentQuestion
    }

    var body: some View {
        VStack(alignment: .center, spacing: 20)
        {
            GeometryReader { proxy in
                Text(
//                    DASIQuestion.with(id: questionID).text)
                    thisQuestion.text)
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(width: proxy.size.width)
                    .fixedSize(horizontal: true, vertical: false)
            }
            Spacer(minLength: 20)

            // FIXME: No way to add a checkmark.
            YesNoView(["Yes", "No"]) {
                choice in
                let usersAnswer: AnswerState = (choice.id == 0) ? .yes : .no
                self.recordAnswer(as: usersAnswer)
                if let nextQueston = thisQuestion.next {
                    prepareForQuestion(nextQueston)
                }
                else {
                    // The response is valid,
                    // but we've run out of questions.
                    // figure out how to bail to the initial screen (or a done screen)
                }
            }


            HStack {
                if let prevQueston = thisQuestion.previous {
                    // Permit previous question any time that .previous is valid.
                    Button {
                        if let pq = thisQuestion.previous {
                            prepareForQuestion(pq)
                        }
                    }
                label: { Text("Back") }
                }
                Spacer()
                Button {
#warning("Do something for Cancel.")
                }
                label: { Text("Cancel") }
                Spacer()
                if let nextQuestion = thisQuestion.next,
                   thisAnswer != .unknown {
                    // Permit next question only when there is an answer, and the question has been responded to.
                    Button {
                        // Record current answer
//                        recordAnswer()
                        // Load next state
                        prepareForQuestion(nextQuestion)
                    }
                label: { Text("Next") }
                }
            }
        }
        .padding()
    }
}

struct DASIQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        DASIQuestionView(
            question: DASIQuestion.with(id: 9)
        )
            .padding()
//            .environmentObject(DASIReport(forSubject: "ABCD"))
    }
}
