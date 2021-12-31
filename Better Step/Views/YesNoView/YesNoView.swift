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
    init(_ titles: [String]) {
        choiceViews = ViewChoice.choices(from: titles)
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
                ZStack {
                    YesNoFrameView(boundingSize: context.size,
                                   count: choiceViews.count)
                    VStack(alignment: .center) {
                        ForEach(choiceViews) {
                            cView in
                            YesNoButton(choice: cView, size: context.size)
                        }
                    }
                }
                Spacer()
            }
        }
        .frame(width: .infinity, alignment: .center)
    }
}

struct YesNoView_Previews: PreviewProvider {
    static let choices: [String] = [
        "Yes", "No"
        ]
    static var previews: some View {
        YesNoView(choices)
    }
}
