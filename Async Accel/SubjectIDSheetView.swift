//
//  SubjectIDSheetView.swift
//  Async Accel
//
//  Created by Fritz Anderson on 3/28/22.
//

import SwiftUI

/* FIXME:
 When and how is this sheet presented after launch
 (when the `UserDefaults` value is `nil`)?

 If upon reporting, does **Proceed** force the
 tab selection?

 If repenting of the setting, is there a way to
 manually clear it?

 Is the sheet presented immediately upon clearing,
 or upon the first-selected working view?
 */

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
    @EnvironmentObject var crappySubjectID: SubjectID

    @State private var scratchID: String = SubjectID.shared.unwrappedSubjectID
    let originalID: String


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
                SubjectUIEditView(id: $scratchID)
                Spacer()
                HStack {
                    Spacer()
                    Button("Cancel", role: .cancel) {
                        crappySubjectID.unwrappedSubjectID = originalID
                        dismiss()
                    }
                    Spacer()
                    Button("Proceed") {
                        crappySubjectID.unwrappedSubjectID = scratchID
                        dismiss()
                    }
                    Spacer()
                }.padding()
                Spacer()
            }
            .navigationTitle("Welcome")
        }
    }
}

struct SubjectIDSheetView_Previews: PreviewProvider {
    static var previews: some View {
//        SubjectID.shared.subjectID = "Shannon"
        return SubjectIDSheetView(originalID: "Throwback")
            .environmentObject(SubjectID.shared)
    }
}
