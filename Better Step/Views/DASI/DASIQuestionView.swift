//
//  DASIQuestionView.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/28/21.
//

import SwiftUI

// FIXME: Senter the action/proceed button
//        When Next is absent, it shifts over to the right.

// MARK: - DASIQuestionView
struct DASIQuestionView: View {
    @State private var thisQuestion: DASIQuestion
    @EnvironmentObject var showingQuestions: BoolBearer
    @EnvironmentObject var reportContents: DASIReportContents

    static let yesNoWidth: CGFloat = 80

//    @Binding var report: DASIReport
//    @State private var thisAnswer: AnswerState

    // Remember question.id starts from 1
    private var thisAnswer: AnswerState {
        return reportContents.responseForQuestion(id: thisQuestion.id)
    }

    private var questionID: QuestionID { thisQuestion.id }

    init(question: DASIQuestion) {
        self.thisQuestion = question
//        thisAnswer = reportContents.responseForQuestion(id: question.id)
    }

    func prepareForQuestion(_ newCurrentQuestion: DASIQuestion) {
        thisQuestion = newCurrentQuestion
    }

    // MARK: Body
    var body: some View {
        VStack(alignment: .center, spacing: 20)
        {
            // MARK: Display instructions
            GeometryReader { proxy in
                Text(
                    thisQuestion.text)
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(width: proxy.size.width)
                    .fixedSize(horizontal: true, vertical: false)
            }
            Spacer(minLength: 20)

            // FIXME: No way to add a checkmark.
            // MARK: Yes/No buttons
            YesNoView(["Yes", "No"]) {
                choice in
                let usersAnswer: AnswerState = (choice.id == 0) ? .yes : .no
                reportContents
                    .didRespondToQuestion(
                        id: thisQuestion.id,
                        with: usersAnswer)

//                self.recordAnswer(as: usersAnswer)
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

            // MARK: Cancel/Next/Back buttons
            HStack {
                // MARK: Back button
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
                }
                label: { Text("Cancel") }
                Spacer()

                /* ********************************************
                 Is there any advantage in making Next and Back into NavigationLinks
                 which can be de/activated with NavigationLink.init(_:tag:selection:destination:)
                 */

                // MARK: Next button
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

// MARK: - Previews
struct DASIQuestionView_Previews: PreviewProvider {
    static let bearer = BoolBearer(initially: false)
    static var previews: some View {
        DASIQuestionView(
            question: DASIQuestion.with(id: QuestionID(9))
        )
            .padding()
            .environmentObject(bearer)
            .environmentObject(DASIReportContents())
    }
}
