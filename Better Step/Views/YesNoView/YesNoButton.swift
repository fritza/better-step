//
//  YesNoButton.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/31/21.
//

import SwiftUI


// MARK: - Frame/color modifier
fileprivate
struct Sizing: ViewModifier {
    let boundSize: CGSize
//    let proxy: GeometryProxy
    let color: Color?
    init(proxy: GeometryProxy,
         color: Color?) {
        self.boundSize = proxy.size
        self.color = color
    }

    func body(content: Content) -> some View {
        content.frame(
            width: boundSize.width,
            height: boundSize.height,
            alignment: .center)
            .background(color)
    }
}

// MARK: Link to View
extension View {
    func bounding(proxy: GeometryProxy,
                  color: Color? = nil) -> some View {
        modifier(Sizing(proxy: proxy, color: color))
    }
}

// MARK: - YesNoButton
struct YesNoButton: View {
    // FIXME: "choiceView" is a bad name for a ViewChoice
    //    let choiceView: ViewChoice
    //    let contextSize: CGSize

    let id: Int
    let title: String
    let completion: ((YesNoButton) -> Void)?

    static let buttonHeight: CGFloat = 48
    static let buttonWidthFactor: CGFloat = 0.9

    init(id: Int, title: String,
         completion: ( (YesNoButton) -> Void)? ) {
        self.id = id
        self.title = title
        self.completion = completion
    }

    // MARK: body
    var body: some View {
        GeometryReader { proxy in
            Button(
                action: {
                    completion?(self)
                },
                label: {
                    Text(self.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .bounding(
                            proxy: proxy,
                            color: Color.black.opacity(0.1))
                        .mask {
                            RoundedRectangle(cornerRadius: 12)
                        }
                })
                .bounding(proxy: proxy)
        }
    }
}

// MARK: - Previews
struct YesNoButton_Previews: PreviewProvider {
    static let choices: [String] = [
                "Yes", "No"
            ]
            static let choice: ViewChoice = {
        ViewChoice(5, "Maybe")
    }()
    static var previews: some View {
        ZStack {
            YesNoButton(id: 1, title: "Seldom") {
                btn in
                print("Beep! button \(btn.title)")
//                btn.spe
            }
        }
        .frame(width: 300, height: 60, alignment: .center)
    }
}
