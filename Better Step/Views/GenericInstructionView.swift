//
//  GenericInstructionView.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/19/21.
//

import SwiftUI

// TODO: Yield to InterstitialPageView
//       which has introAbove and introBelow
#warning("Replace with InterstitialPageView")

struct GenericInstructionView: View {
    private let imageScale: CGFloat = 0.6

    let titleText: String?
    let bodyText: String
    let sfBadgeName: String
    var proceedTitle: String?
    var proceedEnabled: Bool

    // And then we'll have to decide how to handle the "proceed" action
    let proceedClosure: (() -> Void)?

    init(titleText: String? = nil,
         bodyText: String,
         sfBadgeName: String,
         proceedTitle: String? = nil,
         proceedEnabled: Bool = true,
         proceedClosure: ( () -> Void)? = nil) {
       ( self.titleText, self.bodyText, self.sfBadgeName,
         self.proceedTitle, self.proceedTitle) =
        ( titleText, bodyText, sfBadgeName, proceedTitle, proceedTitle)
        self.proceedClosure = proceedClosure
        self.proceedEnabled = proceedEnabled
    }

    var body: some View {
        GeometryReader {
            proxy in
            HStack {
                Spacer()
                VStack {
//                    Spacer()
                    if let tText = titleText {
                        Text(tText)
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .tag("title_text")
                        Spacer()
                    }
                    Image(systemName: sfBadgeName)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.accentColor)
                        .frame(
                            height: proxy.size.width * imageScale, alignment: .center)
                        .tag("image")
                    Spacer()
                    Text(bodyText)
                        .font(.title3)
                        .padding()
                        .minimumScaleFactor(/*@START_MENU_TOKEN@*/0.5/*@END_MENU_TOKEN@*/)
                        .tag("body_text")
                    Spacer()

                    if let proceedTitle {
                        Button(proceedTitle) {
                            proceedClosure?()
                        }
                        .disabled(!proceedEnabled)
                        .tag("continue")
                    }
                }
                Spacer()
            }
        }
//        .padding()
    }
}

struct GenericInstructionView_Previews: PreviewProvider {
    static var previews: some View {
        GenericInstructionView(
            titleText: "☠️ Survey ☠️",
            bodyText: "REPLACE WITH InterstitialPageView.\n\nJust do what we tell you and nobody gets hurt.",
            sfBadgeName: "trash.slash",
            proceedTitle: "Go!") { // do something
            }
            .padding()
            VStack {
                Spacer()
                GenericInstructionView(
//            titleText: "Hollow Survey",
            bodyText: "This view has neither title or action.",
            sfBadgeName: "trash.slash")
                }
    }
}
