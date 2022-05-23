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

/// View that displays and edits app-wide configurations.
///
/// This includes
/// * `.reportAsMagnitude`              — acceleration reported as magnitude rather than vector components.
/// * `.walkInMinutes`                  - Length of the timed walk phases, in minutes
/// * `.reportingEmail`                 - Email address to receive reports; temporary use only.
/// * `.includeWalk`                    - Whether to include timed walks at all.
/// * `.includeDASISurvey`              - Whether to present the DASI survey
/// * `.includeUsabilitySurvey`         - Whether to present the “usability” survey.
///
/// Also, the user can wipe the walk results, the surveys, or the subject ID and all collected data.
struct SetupView: View {

    // FIXME: text field row can't track focus.

    @FocusState private var controlFocus: ControlFocus?

    // MARK: AppStorage

    @AppStorage(AppStorageKeys.reportAsMagnitude      .rawValue) var asMagnitude = false
    @AppStorage(AppStorageKeys.walkInMinutes          .rawValue)  var duration = 6
    @AppStorage(AppStorageKeys.reportingEmail         .rawValue) var email = ""
    @AppStorage(AppStorageKeys.includeWalk            .rawValue)    var includeWalk = true
    @AppStorage(AppStorageKeys.includeDASISurvey      .rawValue)  var includeDASI = true
    @AppStorage(AppStorageKeys.includeUsabilitySurvey .rawValue)  var includeUsability = true
    @AppStorage(AppStorageKeys.inspectionMode         .rawValue)  var proceedAsInspection = false


    @State var      showingClearButtons = false

    var neitherPhaseActive: Bool {
        !(includeWalk || includeDASI)
    }

    // MARK: Form sections
    var walkSection: some View {
        Section("Walk") {
            Toggle("Perform Timed Walks" + (neitherPhaseActive ? " ⚠️" : ""),
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

    var reportingSection: some View {
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
    }

    // MARK: Body
    var body: some View {
        Form {
            // MARK: Presentation
            Section("Presentation") {
                Toggle("Inspection (visit screens freely)",
                       isOn: $proceedAsInspection)
            }

            // MARK: Walks
            walkSection

            // MARK: Surveys
            Section("Surveys") {
                Toggle("Perform DASI Survey" + (neitherPhaseActive ? " ⚠️" : ""),
                       isOn: $includeDASI)
                //includeUsability
                Toggle("Perform Usability Survey",
                       isOn: $includeUsability)
            }
            
            // MARK: Reporting
            reportingSection

            // MARK: Data
            Section("Collected Data") {
#warning("No action on clear-data buttons")
                NavigationLink(isActive: $showingClearButtons) {
                    ClearingView()
                } label: {
                    Text("Clear Data")
                }

            }
        }
        .navigationTitle("Configuration")
    }
}

// MARK: - Previews
struct SetupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SetupView()
        }
        .environmentObject(PhaseManager())
    }
}
