//
//  GenericInstructionView.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/19/21.
//

import SwiftUI

#warning("Replace with an HTML pager (app in mommk")

/// An adaptable framework view for introductions, instructions, interstitial views, etc.
/// - bug: This has to be rewritten for flexibility. See the HTML Pager app in mommk.
struct GenericInstructionView: View {
    private let imageScale: CGFloat = 0.6

    let titleText: String?
    let bodyText: String
    let sfBadgeName: String
    var proceedTitle: String?

    // And then we'll have to decide how to handle the "proceed" action
    let proceedClosure: (() -> Void)?

    init(titleText: String? = nil,
         bodyText: String,
         sfBadgeName: String,
         proceedTitle: String? = nil,
         proceedClosure: ( () -> Void)? = nil) {
       ( self.titleText, self.bodyText, self.sfBadgeName,
         self.proceedTitle, self.proceedTitle) =
        ( titleText, bodyText, sfBadgeName, proceedTitle, proceedTitle)
        self.proceedClosure = proceedClosure
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
                        Spacer()
                    }
                    Image(systemName: sfBadgeName)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.accentColor)
                        .frame(
                            height: proxy.size.width * imageScale, alignment: .center)
                    Spacer()
                    Text(bodyText)
                        .font(.body)
                        .padding()
                        .minimumScaleFactor(/*@START_MENU_TOKEN@*/0.5/*@END_MENU_TOKEN@*/)
                    Spacer()

                    if let title = proceedTitle {
                        Button(title) {
                            proceedClosure?()
                        }
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
            titleText: "Survey",
            bodyText: "Just do what we tell you and nobody gets hurt.",
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
