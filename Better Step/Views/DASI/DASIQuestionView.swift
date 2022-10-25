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
    init(
//        answerList: DASIResponseList,

//         resetAlertVisible: Binding<Bool>,
         _ completion: @escaping ClosureType) {
        self.answerState = .unknown
//        self.answerList = answerList
        self.completion = completion
//        _resetAlertVisible = resetAlertVisible
    }

    let completion: ClosureType
    @EnvironmentObject var answerList: DASIResponseList
//    @State var answerList = DASIResponseList()

    @State var pageNumber: Int = 1
    @State var answerState: AnswerState

//    var answerList: DASIResponseList = DASIResponseList()

    // FIXME: Verify that the report contents don't go away
    // before it's time to report.
    var body: some View {
        VStack {
            QuestionContentView(
                questionIndex: pageNumber)
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
                        completion(
                            .success((.completed, answerList))
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
                            .success((.landing, answerList))
                        )
                    }
                    else {
                        pageNumber -= 1
                    }
                }
            }
//            ToolbarItemGroup(placement: .navigationBarTrailing) {
//                ReversionAlert(shouldShow: $resetAlertVisible)
//                Button("Next →") {
//                    if pageNumber >= DASIStages.maxIdentifier {
//                        completion(
//                            .success((.completed, reportContents))
//                        )
//                    }
//                    else {
//                        pageNumber += 1
//                    }
//                }
//            }
        }
        .navigationTitle(
            "Question \(pageNumber):"
        )
    }
}

struct DASIQuestionView_Previews: PreviewProvider {
    @State static var resetAlertVisible: Bool = false
    static var previews: some View {
        NavigationView {
            DASIQuestionView() {_ in
                print("Question done")
            }
        }
//        .environmentObject(DASIPageSelection(.presenting(questionID: 1)))
//        .environmentObject(DASIResponseList())
    }
}


