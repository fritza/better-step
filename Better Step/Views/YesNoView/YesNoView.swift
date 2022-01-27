//
//  YesNoView.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/29/21.
//

import SwiftUI


// TODO: Generic over some kind of response view (different labels, different response types).

final class ViewChoice: Identifiable {
    let id: Int
    let title: String
    // Add action closure

    init(_ id: Int, _ title: String) {
        (self.id, self.title) = (id, title)
    }

    static func choices(from strings: [String]) -> [ViewChoice] {
        var result: [ViewChoice] = []
        for (n, string) in strings.enumerated() {
            let element = ViewChoice(n, string)
            result.append(element)
        }
        return result
    }
}



struct YesNoView: View {
    var choiceViews: [ViewChoice]
    let completion: (ViewChoice) -> Void

    init(_ titles: [String],
         completion: @escaping (ViewChoice) -> Void) {
        choiceViews = ViewChoice.choices(from: titles)
        self.completion = completion
    }

    let gutterHeight: CGFloat = 8
    func frameHeightFor(buttonCount: Int) -> CGFloat {
        return (CGFloat(buttonCount + 1) * YesNoButton.buttonHeight)
    }

    func outerSize(within boundSize: CGSize,
                   buttonCount: Int) -> CGSize {
        let buttonSize = YesNoButton.buttonSize(within: boundSize)
        return CGSize(
            width: buttonSize.width,
            height: CGFloat(buttonCount) * buttonSize.height)
    }


    var body: some View {
        GeometryReader { context in
            HStack {
                Spacer()
                VStack(alignment: .center) {
                    ForEach(choiceViews) {
                        cView in
                        YesNoButton(
                            choice: cView,
                            size: context.size,
                            completion: completion)
                            .mask {
                                RoundedRectangle(cornerRadius: 14, style: .circular)
                            }
                    }
                }
                Spacer()
            }

        }
    }
}


struct YesNoView_Previews: PreviewProvider {
    static let choices: [String] = [
        "Yes", "No"
    ]
    static var previews: some View {
        VStack {
            YesNoView(choices) {
                _ in
                print("Beep! YNView")
            }
            Spacer()
        }
    }
}
