//
//  InstructionArrows.swift
//  Better Step
//
//  Created by Fritz Anderson on 4/29/22.
//

import SwiftUI

struct InstructionArrows<TagType: Comparable>: View {
    typealias Action = (TagType) -> Void

    let fontHeight: CGFloat
    let tag       : TagType
    let action    : Action?
    let character : String

    init(_ char: String, fontHeight: CGFloat, tag: TagType, action: Action? = nil) {
        self.fontHeight = fontHeight
        self.tag        = tag
        self.action     = action
        self.character  = char
    }

    var caretFont: Font {
        return Font.custom("HelveticaNeue-Bold", size: fontHeight)
            .leading(.loose)
    }

    var body: some View {
        Color(CGColor(gray: 0, alpha: 0.1))
            .overlay(alignment: .center) {
                Text(character)
                    .font(caretFont)
                    .foregroundColor(.white)
                    .alignmentGuide(VerticalAlignment.center) { dims in
                        dims.height - (fontHeight / 2.0)
                    }
            }
            .onTapGesture {
                action?(tag)
            }
    }
}

struct ArrowHolder: View {
    @State var currentText: String = "Initial"
    var body: some View {
        VStack(alignment: .center) {
            Text(currentText)
            InstructionArrows(">", fontHeight: 170.0 * 3.0 / 4.0,
                              tag: "Forward") {
                tag in currentText = tag
            }
            InstructionArrows("<", fontHeight: 170.0 * 3.0 / 4.0,
                              tag: "Back") {
                tag in currentText = tag
            }
        }
    }
}

struct InstructionArrows_Previews: PreviewProvider {
    @State static var theText = "Nope"
    static var previews: some View {
        VStack {
            Text("for rent")
            ArrowHolder()
                .frame(width: 80, height: 230)
        }
    }
}
