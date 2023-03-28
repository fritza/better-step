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
                    if pageNumber >= DASIStages.maxIdentifier {
                        guard answerList.isReadyToPublish else {
                            showIncompletion = true
                            return
                        }
//                        print("Answers:", answerList.csvLine)
                        print("Answers:", "(csv)")
                        completion(
                            .success((.completed, answerList))
                        )
                    }
                    else {
                        pageNumber += 1
                        print("page number advanced to", pageNumber)
                    }
                }
            )
            .frame(height: 130)
            .padding()
        }

/*
 WANTED:
 Now that omitted quiestions can jump you back from the end,
 it would be convenient to offer to (jump to the end?) (jump to the conclusion?)
    ... once you've remedied the incompletion.
 Probably you post an alert with "Proceed" to take you to the conclusion.
 There HAS to be a way to suppress the completion-proceed alert after the first offer.
 You don't want to pop that up every time you re-enter a page.

 How about posting it upon getting a yes/no answer that clears the fault.
 BUT: You can't congratulate and present a proceed button if the one incompletion is upon a regular question 12. It Proceeds when you give your answer

 In existing code (I believe) you try to exit the question series when Q12 is answered.
    If all are completed, proceed to conclusion.
    If not, the "Incomplete" alert and you're jumped back.

 But now you want to be in a BOLO state where the Question View checks for completion at every response
    When that's reached, you offer Proceed (jump to conclusion) or Review (stop showing the alert ever again and allow the user to work further on the answers.
 */


        .alert("Incomplete", isPresented: $showIncompletion) {
            Button("Go") {
                let firstMissingIndex = answerList.unknownResponseIDs.first!
                pageNumber = firstMissingIndex
            }
        } message: {
            Text("Not all questions have been answered. Do back to questions \(answerList.formatUnansweredIDs ?? "program error, sorry)")")
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
        NavigationView {
            DASIQuestionView(startingAtID: 3) {_ in
                print(responseList.csvLine)
//                print("Question 3 drawn")
            }
            .environmentObject(responseList)
        }
    }
}


