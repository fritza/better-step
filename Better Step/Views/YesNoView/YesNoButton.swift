//
//  YesNoButton.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/31/21.
//

import SwiftUI

struct YesNoButton: View {
    let choiceView: ViewChoice
    let contextSize: CGSize

    static let buttonHeight: CGFloat = 48

    func buttonSize() -> CGSize {
        return Self.buttonSize(within: contextSize)
    }

    static func buttonSize(within boundSize: CGSize) -> CGSize {
        CGSize(width: 0.75 * boundSize.width, height: buttonHeight)
    }

    init(choice: ViewChoice,
         size: CGSize) {
        choiceView = choice
        contextSize = size
    }

    var body: some View {
        Button {
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
                    size: CGSize(width: 300, height: 56)
        )
    }
}
