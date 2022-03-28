//
//  SubjectIDSheetView.swift
//  Async Accel
//
//  Created by Fritz Anderson on 3/28/22.
//

import SwiftUI

private let welcomeText = "Welcome to Better Step!\n\nThis app helps your doctor assess your heart health to guide your treatment."

private let paragraph3 = "Type your ID into the form, then tap **Proceed**."

// TODO: Convert the welcome text to Attributed/Markdown
//       SwiftUI has an `AttributedString` struct.
//       BUT it recognizes "only a subset of the
//       attributes defined" for Foundation; or Markdown
//       syntax, particularly paragraph-level markup.
//
//  See
//      Text.init(_:tableName:bundle:comment:)
//      AttributedString.MarkdownParsingOptions enum

struct SubjectIDSheetView: View {
    @Environment(\.dismiss) var dismiss: DismissAction

    func introText(_ str: String) -> AttributedString {
        do {
            return try AttributedString(markdown: str)
        }
        catch {
            return AttributedString(str)
        }

    }
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Group {
                    Text(welcomeText)
                    Text(introText(paragraph3))
                }
                .padding([.leading, .trailing, .bottom])

                // FIXME: Forced empirical height.
                //        Within SubjectUIEditView

                // TODO: Is "Proceed" obscured by the keyboard?
                SubjectUIEditView()
                    Spacer()
                    HStack {
                        Spacer()
                        Button("Proceed") {}// dismiss() }
                        Spacer()
                    }
                    Spacer()
            }
            .navigationTitle("Welcome")
        }
    }
}

struct SubjectIDSheetView_Previews: PreviewProvider {
    static var previews: some View {
        SubjectID.shared.subjectID = "Shannon"
        return SubjectIDSheetView()
    }
}
