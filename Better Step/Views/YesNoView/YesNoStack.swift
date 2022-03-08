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

struct YesNoStack: View {
    typealias AnswerVoid = ((AnswerState) -> Void)

    @State var currentAnswer = AnswerState.unknown
    @Binding var boundState: AnswerState
    let completion: ((AnswerState) -> Void)?

    init(boundState: Binding<AnswerState>
         , completion: AnswerVoid?
    )
    {
        self._boundState = boundState
        self.completion = completion
    }

    func selectButton(id button: YesNoButton) {
        switch button.id {
        case 1: currentAnswer  = .yes
        case 2: currentAnswer  = .no
        default: currentAnswer = .unknown
        }
        boundState = currentAnswer
        completion?(currentAnswer)
    }

    var body: some View {
        VStack {
            YesNoButton(
                id: 1, title: "Yes",
                completion: selectButton(id:)
            )
            Spacer(minLength: 24)
            YesNoButton(
                id: 2, title: "No",
                completion: selectButton(id:))
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
    @State static var last: String = "NONE"
    static var previews: some View {
        VStack {
            YesNoStack(boundState: ynuState.$answer
            , completion: nil)
            .frame(height: 160, alignment: .center)
        }
    }
}
