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
    }
}

// MARK: Link to View
extension View {
    func bounding(proxy: GeometryProxy,
                  color: Color? = nil) -> some View {
        modifier(Sizing(proxy: proxy, color: color))
    }
}

extension String {
    func asChecked(_ checked: Bool) -> String {
        (checked ? "✓ " : "  ") + self
    }
}

// MARK: - YesNoButton
struct YesNoButton: View {
    // FIXME: "choiceView" is a bad name for a ViewChoice
    //    let choiceView: ViewChoice
    //    let contextSize: CGSize

    @EnvironmentObject var reportContents: DASIResponseList

    // FIXME: Direct access to the content state
    @EnvironmentObject var envt: DASIPages

    let id: Int
    let title: String
    let completion: ((YesNoButton) -> Void)?
    @State var isChecked = false

    static let buttonHeight: CGFloat = 48
    static let buttonWidthFactor: CGFloat = 0.9

    var shouldBeChecked: Bool {
        // FIXME: Direct access to the content state
        guard let currentID = envt.questionIdentifier,
              let answer = reportContents.responseForQuestion(identifier: currentID)
        else {
            return false
        }
        switch answer {
        case .no: return self.id == 2
        case .unknown: return false
        case .yes: return self.id == 1
        }
    }

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
                    Text(self.title.asChecked(shouldBeChecked)
                    )
                        .font(.title2)
                        .fontWeight(.semibold)
                        .bounding(proxy: proxy)
                })
                .bounding(proxy: proxy)
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle(radius: 12)
                )
        }
    }
}

// MARK: - Previews
struct YesNoButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
//            Color(.red)
            YesNoButton(id: 1, title: "Seldom") {
                btn in
                btn.isChecked.toggle()
//                print("Beep! button \(btn.title)")
            }

//            Color.green
        }
        .padding()
        .frame(width: 300, height: 80, alignment: .center)
    }
}
