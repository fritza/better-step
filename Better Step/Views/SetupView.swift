//
//  SetupView.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/19/21.
//

import SwiftUI

struct ThingToClear: Identifiable, Comparable {
    let title: String
    let enabled: Bool
    let id: Int

    init(nameAbleID: (String, Bool, Int)) {
        title = nameAbleID.0
        enabled = nameAbleID.1
        id = nameAbleID.2
    }

    static func == (lhs: ThingToClear, rhs: ThingToClear) -> Bool {
        rhs.id == lhs.id
    }

    static func < (lhs: ThingToClear, rhs: ThingToClear) -> Bool {
        rhs.id > lhs.id
    }
}

let clearingTitles: [(String, Bool, Int)] = [
    ("Clear Survey", true, 1),
    ("Clear Timed Walk", false, 2),
    ("Clear Subject", true, 3)
]
let thingsToClear: [ThingToClear] = {
    clearingTitles.map {
        ThingToClear(nameAbleID: $0)
    }
}()

func performClear(for tag: Int) {   // might throw
    switch tag {
    case 1:     DASIResponseList.clearResponses()
    case 2:     break
                // FIXME: Not implemented.
    case 3:
        DASIResponseList.clearResponses()
    default:
        assertionFailure("Unknown tag (\(tag)) for a clear button.")
        return
    }

}


@available(*, unavailable, message: "Use RootStorage or document environment objects.")
final class Configurations: ObservableObject, CustomStringConvertible {
    var emailAddress: String
    var durationInMinutes: Int

    var description: String {
        let emailString = emailAddress
        let durationString = String(describing: durationInMinutes)
        return "Configurations(email: \(emailString), duration: \(durationString))"
    }

    init(startingEmail: String, duration: Int) {
        emailAddress      = "" // startingEmail
        durationInMinutes = 6 // duration
    }
}

private enum ControlFocus: String {
    case emailField
    case durationStepper
}

struct ClearingButton: View {
//    @Environment(\.dismiss) private var dismiss

    @Binding var shouldShow: Bool
    let thing: ThingToClear

    var body: some View {
        Button(action: { shouldShow = true },
               label : { Text(thing.title) }
        )
        .disabled(!thing.enabled)
        .alert(thing.title + "?",
               isPresented: $shouldShow,
               actions: {
            Button("Yes.") {
                shouldShow = false
            }
        })
    }
}

// TODO: Add confirmation to destructive actions
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
                Button("Clear Survey") {
                    Task {
                        // NOTE: Bug risk.
                        await DASIResponseList.clearAllDASI()
                    }
                }
                Button("Clear Timed Walk") {
                    #warning("unimplemented.")
//                    RootState.shared.
                }
                Button("Clear Subject (all)") {
                    Task {
                        // NOTE: Bug risk.
                        RootState.shared.subjectIDSubject.send(nil)
                        await DASIResponseList.clearAllDASI()
                        // TODO: Clear walk.
                    }
                }

//                ForEach(thingsToClear.sorted()) { thing in
//                    // NOPE.
//                    // ClearingButton isolated in a ClearingView seems to show the right alert for the label of the button.
//
//                    // In SetupView, the alert text usually doesn't match the label.
//
//                    ClearingButton(shouldShow: $showingAlert,
//                                   thing: thing)
//                    .padding()
//                }
            }
        }
        .navigationTitle("Clear Data")
        .toolbar {
            Button("Done", action: {dismiss()})
        }
    }
}

struct ClearingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ClearingView()
                .navigationTitle("Clear")
        }
    }
}

struct SetupView: View {
    // FIXME: text field row can't track focus.

    @FocusState private var controlFocus: ControlFocus?

    @AppStorage(AppStorageKeys.reportAsMagnitude.rawValue) var asMagnitude = false
    @AppStorage(AppStorageKeys.walkInMinutes.rawValue)  var duration = 6
    @AppStorage(AppStorageKeys.reportingEmail.rawValue) var email = ""
    @AppStorage(AppStorageKeys.includeWalk.rawValue)    var includeWalk = true
    @AppStorage(AppStorageKeys.includeSurvey.rawValue)  var includeSurvey = true


    var neitherPhaseActive: Bool {
        !(includeWalk || includeSurvey)
    }

    var body: some View {
        NavigationView {
            Form {
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
                Section("DASI Survey") {
                    Toggle("Perform DASI Survey" + (neitherPhaseActive ? " ⚠️" : ""),
                           isOn: $includeSurvey)
                }

                Section("Reporting") {
                    Toggle("Report as magnitude",
                           isOn: $asMagnitude)
                    // FIXME: need a binding for the email
                    EmailFormView(
                        title: "Email",
                        address: $email)
                    //  .border(.blue)
                }
                Section("Collected Data") {


/*
 View.confirmationDialog(_:isPresented:titleVisibility:presenting:actions:message:)
 Remember the .cancel and .destructive Button roles
 */


                    #warning("No action on clear-data buttons")
                    NavigationLink(
                        "Clear Data",
                        destination: {
                        ClearingView()
                            .navigationBarBackButtonHidden(true)
                    })
                }
            }
            .navigationTitle("Configuration")
        }
        .onDisappear() {
            assert(includeWalk || includeSurvey,
                   "Finished SetupView with neither data phase set")
            // FIXME: Check/enforce the condition.
        }
    }
}

struct SetupView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SetupView()
        }
    }
}
