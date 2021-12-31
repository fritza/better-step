//
//  YesNoButton.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/31/21.
//

import SwiftUI

struct YesNoButton: View {
    // FIXME: "choiceView" is a bad name for a ViewChoice
    let choiceView: ViewChoice
    let contextSize: CGSize
    let completion: ((ViewChoice) -> Void)?

    static let buttonHeight: CGFloat = 48
    static let buttonWidthFactor: CGFloat = 0.9

    func buttonSize() -> CGSize {
        return Self.buttonSize(within: contextSize)
    }

    static func buttonSize(within boundSize: CGSize) -> CGSize {
        CGSize(width: buttonWidthFactor * boundSize.width,
               height: buttonHeight)
    }

    init(choice: ViewChoice,
         size: CGSize,
         completion: ( (ViewChoice) -> Void)? ) {
        choiceView = choice
        contextSize = size
        self.completion = completion
    }

    var body: some View {
        Button {
            completion?(choiceView)
            print("ho")
        } label: {
            Text(choiceView.title)
        }
        .frame(
            width: buttonSize().width,
            height: buttonSize().height)
        .background(Color.black.opacity(0.05))
    }
}

struct YesNoButton_Previews: PreviewProvider {
    static let choices: [String] = [
        "Yes", "No"
        ]
    static let choice: ViewChoice = {
        ViewChoice(5, "Maybe")
    }()
    static var previews: some View {
        YesNoButton(choice: Self.choice,
                    size: CGSize(width: 300, height: 56)) {
            _ in
            print("Beep! YNButton")
        }
    }
}
