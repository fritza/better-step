//
//  DASIQuestionView.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/28/21.
//

import SwiftUI

// FIXME: Senter the action/proceed button
//        When Next is absent, it shifts over to the right.

struct DASIQuestionView: View {
    @State private var thisQuestion: DASIQuestion
    @EnvironmentObject var showingQuestions: BoolBearer
    @EnvironmentObject var reportContents: DASIReportContents

    static let yesNoWidth: CGFloat = 80

//    @Binding var report: DASIReport
//    @State private var thisAnswer: AnswerState

    // Remember question.id starts from 1
    private var thisAnswer: AnswerState {
        return report.responseForQuestion(id: thisQuestion.id)
    }


    var report: DASIReportContents { myDocument.report }
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
                    // FIXME: Should be complete()
                    showingQuestions.greet()
//                    showingQuestions.isSet = false
                    // The response is valid,
                    // but we've run out of questions.
                }
            }


            HStack {
                if thisQuestion.previous != nil {
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
                    showingQuestions.greet()
//                    showingQuestions.isSet = false
                }
                label: { Text("Cancel") }

                /* ********************************************
                 Is there any advantage in making Next and Back into NavigationLinks
                 which can be de/activated with NavigationLink.init(_:tag:selection:destination:)
                 this initializer doesn't display a UI, it just triggers the
                 destination if selection matches the tag value.
                 ^ Spoke too soon. SwiftUI derives the label view contents
                 from the title.

                 Am I supposed to do some kind of submit (see .onSubmit modifier) event
                 and then rewrite the document contents? That's bad news if you have
                 10,000 lines.

                 (BTW: you could iterate the file with URL.lines and
                 inject a new line. But that requires hauling the whole thing in and
                 writing it out.)
                 */

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
    static let bearer = BoolBearer(initially: false)
    static var previews: some View {
        DASIQuestionView(
            question: DASIQuestion.with(id: 9)
        )
            .padding()
            .environmentObject(bearer)
            .environmentObject(DASIReportDocument())
    }
}
