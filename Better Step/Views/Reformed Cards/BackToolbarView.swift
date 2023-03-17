//
//  BackToolbarView.swift
//  Gallery
//
//  Created by Fritz Anderson on 3/15/23.
//

import SwiftUI

struct BackToolbarView: View {
    let backCallback: () -> Void
    let title: String
    var disabled: Bool
    init(title: String = "< Back", disabled: Bool, _ callback: @escaping () -> Void) {
        self.disabled = disabled
        self.backCallback = callback
        self.title = title
    }
    var body: some View {
        VStack {
            HStack {
                Button(title) {
                    backCallback()
                }
                .disabled(disabled)
                .font(.headline)
                Spacer()
            }
            Divider()
        }
        .padding()
    }
}

struct BackToolbarView_Previews: PreviewProvider {
    static let nameFont: KeyValuePairs<String, Font> = [
        "Large Title": .largeTitle,
        "Title": .title, "Title 2": .title2, "Title 3": .title3,
        "Headline": .headline,
        "Body": .body
        ]
    static var previews: some View {
        VStack {
            BackToolbarView(disabled: true) {
                print("Get back")
            }
            Button("< Back") { }
            Spacer()
            List(nameFont, id: \.0) { kvPair in
                LabeledContent(kvPair.0) {
                    Text("Some Text")
                        .font(kvPair.1)
                }
            }
        }
    }
}
