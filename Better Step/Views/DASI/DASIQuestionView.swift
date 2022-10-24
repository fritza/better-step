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

struct DASIQuestionView: View, ReportingPhase {
    typealias SuccessValue = (DASIState, DASIResponseList)
    // .landing for underflow, .completion for overflow.
    init(answerList: DASIResponseList, _ completion: @escaping ClosureType) {
        self.answerState = .unknown
        self.answerList = answerList
        self.completion = completion
    }

    let completion: ClosureType
    @EnvironmentObject var reportContents: DASIResponseList
    @State var pageNumber: Int = 1
    @State var answerState: AnswerState

    var answerList: DASIResponseList

    // FIXME: Verify that the report contents don't go away
    // before it's time to report.
    var body: some View {
        VStack {
            QuestionContentView(
                questionIndex: pageNumber)
            .padding()

            Spacer()

            YesNoStack(
                answer: reportContents.responseForQuestion(identifier: pageNumber)!,
                completion: { state in
                    guard let answer = try? state.get() else {
                        print(#function, "- got an error answer.")
                        return
                    }
                    reportContents
                        .didRespondToQuestion(
                            id: pageNumber,
                            with: answer)
                    if pageNumber >= DASIStages.maxIdentifier {
                        completion(
                            .success((.completed, reportContents))
                        )
                    }
                    else {
                        pageNumber += 1
                    }
                }
            )
            .frame(height: 130)
            .padding()
        }

        .animation(.easeInOut, value: pageNumber)

        .toolbar {
            // TODO: Replace with ToolbarItem
            ToolbarItem(placement: .navigationBarLeading) {
                Button("← Back") {
                    if pageNumber <= DASIStages.minIdentifier {
                        completion(
                            .success((.landing, reportContents))
                        )
                    }
                    else {
                        pageNumber -= 1
                    }
                }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                gearBarItem()
                Button("Next →") {
                    if pageNumber >= DASIStages.maxIdentifier {
                        completion(
                            .success((.completed, reportContents))
                        )
                    }
                    else {
                        pageNumber += 1
                    }
                }
            }
        }
        .navigationTitle(
            "Question \(pageNumber):"
        )
    }
}

struct DASIQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DASIQuestionView(answerList: DASIResponseList()) {_ in
                print("Question done")
            }
        }
//        .environmentObject(DASIPageSelection(.presenting(questionID: 1)))
//        .environmentObject(DASIResponseList())
    }
}


