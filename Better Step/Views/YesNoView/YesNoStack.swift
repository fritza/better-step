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
    var selectedButtonID: Int {
        return currentAnswer.ynButtonNumber
    }
    var callback: AnswerVoid? = nil

    init(state: AnswerState, completion: AnswerVoid?) {
        self.currentAnswer = state
        self.callback = completion
    }



    func selectButton(id button: YesNoButton) {
        switch button.id {
        case 1: currentAnswer  = .yes
        case 2: currentAnswer  = .no
        default: currentAnswer = .unknown
        }
        callback?(currentAnswer)
    }

    var body: some View {
        VStack {
            YesNoButton(
                id: 1,
                title: "Yes".asChecked(
                    currentAnswer == .yes),
                completion: selectButton(id:)
            )
            Spacer(minLength: 24)
            YesNoButton(
                id: 2,
                title: "No".asChecked(currentAnswer == .no),
                completion: selectButton(id:))
            Spacer()
        }
        .padding()
    }
}

struct YesNoStack_Previews: PreviewProvider {
    @State static var last: String = "NONE"
    static var previews: some View {
        VStack {
            YesNoStack(state: .no, completion: nil)
            .frame(height: 160, alignment: .center)
        }
    }
}
