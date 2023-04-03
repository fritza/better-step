//
//  DASIQuestionView.swift
//  CardSeries
//
//  Created by Fritz Anderson on 3/4/22.
//

import SwiftUI

struct QuestionContentView: View {
    //    let content: String
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

/// Present a question number, question text, and a yes/no button stack.
///
/// The ``SuccessValue`` as a ``ReportingPhase`` is `(DASIState`, `DASIResponseList)`.
struct DASIQuestionView: View, ReportingPhase {
    typealias SuccessValue = (DASIState, DASIResponseList)
    // .landing for underflow, .completion for overflow.
    let completion: ClosureType

    // answerList is by-reference, but
    // make it view-persistent out of an abundance.
    @EnvironmentObject var answerList: DASIResponseList

    @State var pageNumber: Int = 1
    @State var showIncompletion = false
    @State var showCompletion   = false

    init(startingAtID id: Int = 1, completion: @escaping ClosureType) {
        self.pageNumber = id
        self.completion = completion
    }


    // FIXME: Verify that the report contents don't go away
    // before it's time to report.
    var body: some View {
        VStack {
            QuestionContentView(
                questionIndex: pageNumber)
            .multilineTextAlignment(.leading)
            .padding()

            Spacer()

            YesNoStack(
                answer: answerList.responseForQuestion(identifier: pageNumber)!,
                completion: { state in
                    guard let answer = try? state.get() else {
                        print(#function, "- got an error answer.")
                        return
                    }
                    answerList
                        .didRespondToQuestion(
                            id: pageNumber,
                            with: answer)

                    if answerList.isReadyToPublish {
                        // all purposes, including Q12.
                        showCompletion = true
                    }
                    else if (pageNumber + 1) > DASIStages.maxIdentifier && !answerList.isReadyToPublish {
                        showIncompletion = true
                    }
                    else {
                        pageNumber += 1
                    }
                }
            )
            .frame(height: 130)
            .padding()
        }
        .alert("Incomplete", isPresented: $showIncompletion) {
            Button("Go") {
                let firstMissingIndex = answerList.unknownResponseIDs.first!
                pageNumber = firstMissingIndex
            }
        } message: {
            Text("Not all questions have been answered. Do back to questions \(answerList.formatUnansweredIDs ?? "program error, sorry)")")
        }

        .alert("Finished!", isPresented: $showCompletion) {
            Button("Save") {
                completion(.success((.completed, answerList)))
            }
            Button("Review", role: .cancel) {
                // Do nothing, the alert will clear showCompletion.
            }
        } message: {
            VStack {
                Text("You’ve answered all the questions in the survey.\nYou can save all your answers, or continue reviewing your answers.")
            }
        }


        .animation(.easeInOut, value: pageNumber)

        .toolbar {
            // TODO: Replace with ToolbarItem
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button("← Back") {
                    if pageNumber <= DASIStages.minIdentifier {
                        completion(
                            .success((.landing, answerList))
                        )
                    }
                    else { pageNumber -= 1 }
                }
            }

            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Next →") {
                    if pageNumber < DASIStages.maxIdentifier {
                        pageNumber += 1
                    }
                }
                .disabled(pageNumber >= DASIStages.maxIdentifier)
            }
        }
        .navigationTitle("Question \(pageNumber):")
    }
}

struct DASIQuestionView_Previews: PreviewProvider {
    static let responseList = DASIResponseList()
    static var previews: some View {
        NavigationView {
            DASIQuestionView() {_ in
                print(responseList.csvLine)
//                print("Question 1 drawn")
            }
            .environmentObject(responseList)
        }
    }
}


