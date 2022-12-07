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

/// A stack of `YesNoButtonView`s, one **Yes**, one **No**
///
/// Its ``SuccessValue`` as a ``ReportingPhase`` is ``AnswerState`` (`.yes`, `.no`, `.unknown`).
struct YesNoStack: View, ReportingPhase {
    typealias SuccessValue = AnswerState
    let completion: ClosureType

    private let currentAnswer: AnswerState

    /// Create the view with an initial ``AnswerState`` (which may be `.unknown`)
    init(answer: AnswerState,
         completion: @escaping ClosureType) {
        self.completion = completion
        self.currentAnswer = answer
    }

    var body: some View {
        VStack {
            YesNoButtonView(title: "Yes", checked: (currentAnswer == .yes)) { yesAnswer in
                completion(.success(.yes))
            }
            YesNoButtonView(title: "No" , checked: (currentAnswer == .no )) { noAnswer in
                completion(.success(.no))
            }
            Spacer()
        }
        .padding()
    }
}

private final class YNUState: ObservableObject {
    @State var answer: AnswerState = .no
}

struct YesNoStack_Previews: PreviewProvider {
//    @StateObject fileprivate static var ynuState = YNUState()
    fileprivate static let ynuState = YNUState()
    @State private static var yesCount      : Int = 0
    @State private static var noCount       : Int = 0
    @State private static var illegalCount  : Int = 0
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
