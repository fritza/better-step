//
//  SetupView.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/19/21.
//

import SwiftUI

// clearingTitles -> thingsToClear are now in clearingView.

private enum ControlFocus: String {
    case emailField
    case durationStepper
}


// TODO: Add confirmation to destructive actions

struct SetupView: View {
    // FIXME: text field row can't track focus.

    @FocusState private var controlFocus: ControlFocus?

    @AppStorage(AppStorageKeys.reportAsMagnitude.rawValue) var asMagnitude = false
    @AppStorage(AppStorageKeys.walkInMinutes.rawValue)  var duration = 6
    @AppStorage(AppStorageKeys.reportingEmail.rawValue) var email = ""
    @AppStorage(AppStorageKeys.includeWalk.rawValue)    var includeWalk = true
    @AppStorage(AppStorageKeys.includeSurvey.rawValue)  var includeSurvey = true

    @State var      showingClearButtons = false

    var neitherPhaseActive: Bool {
        !(includeWalk || includeSurvey)
    }

    var walkSection: some View {
        Section("Walk") {
            Toggle("Perform Timed Walk" + (neitherPhaseActive ? " ⚠️" : ""),
                   isOn: $includeWalk)
            Stepper("Duration (\(self.duration)):",
                    value: $duration,
                    in: AppStorageKeys.dasiWalkRange,
                    step: 1,
                    onEditingChanged: { _ in
                controlFocus = nil
            })
        }
    }

    var body: some View {
        Form {
            walkSection
            Section("DASI Survey") {
                Toggle("Perform DASI Survey" + (neitherPhaseActive ? " ⚠️" : ""),
                       isOn: $includeSurvey)
            }

            Section("Reporting") {
                Toggle(
                    "Report as magnitude  —  "
                    + (asMagnitude ? "|a|" : " a⃑")
                    ,
                    isOn: $asMagnitude)
                // FIXME: need a binding for the email
                EmailFormView(
                    title: "Email",
                    address: $email)
                Text("for testing only").font(.caption)
            }
            Section("Collected Data") {
#warning("No action on clear-data buttons")
//                NavigationLink("Clear Data", isActive: $showingClearButtons, destination: {
//                    ClearingView()
////                        .navigationBarBackButtonHidden(true)
//                })
                NavigationLink(isActive: $showingClearButtons) {
                    ClearingView()
                } label: {
                    Text("Clear Data")
                }

            }
            .navigationTitle("Configuration")
            .onDisappear() {
//                assert(includeWalk || includeSurvey,
//                       "Finished SetupView with neither data phase set")
                // FIXME: Check/enforce the condition.
            }
        }
    }
}

    struct SetupView_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                VStack {
                    SetupView()
                }
            }
            .environmentObject(PhaseManager())
        }
    }
