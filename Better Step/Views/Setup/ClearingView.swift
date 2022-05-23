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
//    @State private var latestClick = ""
    @EnvironmentObject var appStageState: AppStageState
    // @EnvironmentObject var phaseManager: PhaseManager
    @EnvironmentObject var dasiResponses: DASIResponseList

    @State var showClearDASI: Bool = false
    @State var showClearWalk: Bool = false
    @State var showClearAll : Bool = false

    var body: some View {
        VStack(alignment: .center, spacing: 80.0) {
            List {
                Button("Clear Surveys") {
                    showClearDASI = true
                }
                .confirmationDialog("Clearing Surveys",
                                    isPresented: $showClearDASI,
                                    actions: {
                    Button("Clear DASI & Usability", role: .destructive) {
                        print("clearing survey")
                    }
                }, message: {
                    Text("Do you want to clear the usability and DASI responses? This cannot be undone,")
                })

                Button("Clear Timed Walks") {
                    showClearWalk = true
                }
                .confirmationDialog("Clearing Walk Data",
                                    isPresented: $showClearWalk,
                                    actions: {
                    Button("Clear Walk", role: .destructive) {
                        print("clearing walk")
                    }
                }, message: {
                    Text("Do you want to clear all walking-test records? This cannot be undone,")
                })


                Button("Clear Subject (all)") {
                    showClearAll = true
                }
                .confirmationDialog("Clearing the Subject",
                                    isPresented: $showClearAll,
                                    actions: {
                    Button("Clear ALL", role: .destructive) {
                        print("clearing subject")
                    }
                }, message: {
                    Text("Do you want to clear the subject ID and all its records? This cannot be undone.")
                })
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                HStack {
                    Button("Done") {  dismiss() }
                }
            }
        }
        .navigationTitle("Clear Data")
    }
}

struct ClearingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ClearingView()
        }
        .environmentObject(PhaseManager())
    }
}
