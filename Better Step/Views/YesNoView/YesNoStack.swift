//
//  YesNoStack.swift
//  CardSeries
//
//  Created by Fritz Anderson on 3/4/22.
//

import SwiftUI

/*
 RATS RATS RATS

 I think it might be best to bind the button selection so the stack sets/unsets the answer in client code.
 */

struct YesNoStack: View, ReportingPhase {
    typealias SuccessValue = AnswerState
    let completion: ClosureType


    let currentAnswer: AnswerState
//    @State var currentAnswer = AnswerState.unknown
//    @Binding var boundState: ClosureType

    init(answer: AnswerState,
         completion: @escaping ClosureType) {
        self.completion = completion
        self.currentAnswer = answer
    }



//    func selectButton(id button: YesNoButton) {
//        switch button.id {
//        case 1: currentAnswer  = .yes
//        case 2: currentAnswer  = .no
//        default: currentAnswer = .unknown
//        }
//        boundState = currentAnswer
//        completion(currentAnswer)
//    }

    var body: some View {
        VStack {
            YesNoButtonView(title: "Yes", checked: (currentAnswer == .yes)) { yesAnswer in
//                currentAnswer = .yes
                completion(.success(.yes))
            }
            YesNoButtonView(title: "No" , checked: (currentAnswer == .no )) { noAnswer in
//                currentAnswer = .no
                completion(.success(.no))
            }
            Spacer()
        }
        .padding()
    }
}

final class YNUState: ObservableObject {
    @State var answer: AnswerState = .no
}

struct YesNoStack_Previews: PreviewProvider {
    static let ynuState = YNUState()
    @State static var yesCount: Int = 0
    @State static var noCount : Int = 0
    @State static var illegalCount : Int = 0
    static var previews: some View {
        VStack {
            YesNoStack(answer: .unknown, completion: { answerYesOrNo in
                let rawAnswer = try! answerYesOrNo.get()
                switch rawAnswer {
                case .yes: yesCount += 1
                case .no : noCount  += 1
                case .unknown: illegalCount += 1
                }
            })
            .frame(height: 160, alignment: .center)

            Text("Y: \(yesCount) - N: \(noCount) - U: \(illegalCount)")
        }
    }
}
