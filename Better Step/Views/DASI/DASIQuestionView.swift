//
//  DASIQuestionView.swift
//  CardSeries
//
//  Created by Fritz Anderson on 3/4/22.
//

import SwiftUI

// FIXME: Replace with dumber DASIQuestionView
//        (just the content and response), let superview
//        handle the navigation. (May not be possible?)
//        See if there's a QuestionPresenting protocol here.

struct QuestionContentView: View {
    let content: String
    let questionIndex: Int
    var text: String {
        DASIQuestionState
            .with(id: questionIndex).text
    }
    var body: some View {
        Text(self.text)
            .font(.title)
            .minimumScaleFactor(0.5)
    }
}

/// Presents DASI questions as a sequence of question tex + Yes/No buttons for each.
///
/// Reflect existing answers with checkmarks on the **Yes** or **No** buttons
struct DASIQuestionView: View {
    /// Track a current selection among questions.
    @EnvironmentObject var pageCursor: DASIPages
    @EnvironmentObject var reportContents: DASIResponseList
    @State var answerState: AnswerState

    /// Reflect the current question after incrementing or decrementing the question ID.
    func updateForNewBinding() {
        let answerState: AnswerState
        if let qID = pageCursor.questionIdentifier,
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
        if let qID = pageCursor.questionIdentifier {
            VStack {
                QuestionContentView(
                    content: "Do you have difficulty?",
                    questionIndex: qID)
                .padding()

                Spacer()
                YesNoStack(
                    boundState: self.$answerState,
                    completion: { state in
#warning("How many times do we do this?")
                        reportContents
                            .didRespondToQuestion(
                                id: qID,
                                with: state)
                        pageCursor.increment()
                        updateForNewBinding()
                    }
                )
                .frame(height: 130)
                .padding()
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("← Back") {
                        pageCursor.decrement()
                        updateForNewBinding()
                    }
                    .disabled(pageCursor.selected <= DASIStages.minPresenting)
                    gearBarItem()
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Next →") {
                        pageCursor.increment()
                        updateForNewBinding()
                    }
                    .disabled(pageCursor.selected >= DASIStages.maxPresenting)
                }
            }
            .navigationTitle(
                "Question \(qID.description ?? "NO ID"):"
            )
        }
        else {
            EmptyView()
        }
    }
}

struct DASIQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DASIQuestionView(answerState: .yes)
        }
        .environmentObject(DASIPages(.presenting(questionID: 2)))
        .environmentObject(DASIResponseList())
    }
}


