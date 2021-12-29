//
//  GenericInstructionView.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/19/21.
//

import SwiftUI

struct GenericInstructionView: View {
    private let imageScale: CGFloat = 0.6

    let titleText: String
    let bodyText: String
    let sfBadgeName: String
    var proceedTitle: String

    // And then we'll have to decide how to handle the "proceed" action
    let proceedClosure: () -> Void

    init(titleText: String,
         bodyText: String,
         sfBadgeName: String,
         proceedTitle: String = "Proceed",
         proceedClosure: @escaping () -> Void) {
       ( self.titleText, self.bodyText, self.sfBadgeName, self.proceedTitle, self.proceedTitle) =
        ( titleText, bodyText, sfBadgeName, proceedTitle, proceedTitle)
        self.proceedClosure = proceedClosure
    }

    var body: some View {
        GeometryReader {
            proxy in
            HStack {
                Spacer()
                VStack {
                    Text(titleText)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: sfBadgeName)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.accentColor)
                        .frame(
                            height: proxy.size.width * imageScale, alignment: .center)
                    Spacer()
                    Text(bodyText)
                        .font(.body)
                    Spacer()

                    Button(proceedTitle) {
                        proceedClosure()
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
        GenericInstructionView(titleText: "Survey",
                               bodyText: "Just do what we tell you and nobody gets hurt.",
                               sfBadgeName: "trash.slash",
                               proceedTitle: "Go!") {
            // do something
        }
    }
}
