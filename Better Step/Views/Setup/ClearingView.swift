//
//  ClearingView.swift
//  Better Step
//
//  Created by Fritz Anderson on 4/1/22.
//

import SwiftUI

#if FOR_BETTER_ST
let clearingTitles: [(String, Bool, Int)] = [
    ("Clear Survey", true, 1),
    ("Clear Timed Walk", false, 2),
    ("Clear Subject", true, 3)
]
#else
let clearingTitles: [(String, Bool, Int)] = [
    ("Clear Timed Walk", false, 2),
    ("Clear Subject", true, 3)
]
#endif


let thingsToClear: [ThingToClear] = {
    clearingTitles.map {
        ThingToClear(nameAbleID: $0)
    }
}()

/*
 1. Defer actual clearing unti the Done button is tapped.
 2. upon clear or done, return to the parent setup view.
 3. Update the tab badge.
 4. I guess the setup view doesn't _have_ to change user state.
 5. When you return to any activity tab (walk, DASI), present the subject-id sheet.
 */

/// A view that presents a stack of buttons for clearing part or all of the data collected for the current user.
///
/// Presented by `SetupView`.
/// - bug: Actions are not yet implemented.
struct ClearingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingAlert = false

    @State private var latestClick = ""

    var body: some View {
        VStack(alignment: .center, spacing: 80.0) {
            List {
                #if FOR_BETTER_ST
                Button("Clear Survey") {
                    Task {
                        // NOTE: Bug risk.
                        AppStageState.shared.dasiResponses.teardownFromSubjectID
                    }
                }
#endif
                Button("Clear Timed Walk") {
#warning("unimplemented for walk")
                }
                Button("Clear Subject (all)") {
#if FOR_BETTER_ST
                   _ = try?  AppStageState.shared.tearDownFromSubject()
#warning("unimplemented for walk")
#endif
                }
            }
        }
        .navigationTitle("Clear Data")
        .toolbar {
            ToolbarItemGroup {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                Spacer()
                Button("Done", role: .destructive)  {
                    // execute any clears
                    dismiss()
                }
            }
        }
    }
}

struct ClearingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ClearingView()
        }
    }
}
