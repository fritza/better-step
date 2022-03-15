//
//  SetupView.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/19/21.
//

import SwiftUI

@available(*, unavailable, message: "Use AppStorage or document environment objects.")
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

struct ClearingView: View {
    @State private var lastID: Int = 0

   let clearingTitles: [(String, Bool, Int)] = [
        ("Clear Survey", true, 1),
        ("Clear Timed Walk", true, 2),
        ("Clear Subject", true, 3)
    ]

//    @State var saying: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .center, spacing: 80.0){
            List {
                ForEach(clearingTitles, id: \.self.0) { pair in
                    Button(action: {
                        lastID = pair.2
                    }, label: {
                        Text(pair.0)
                    })
                    .disabled(!pair.1)
                    .padding()
                }
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
    @AppStorage(AppStorageKeys.subjectID.rawValue)      var subjectID = ""
    @AppStorage(AppStorageKeys.includeWalk.rawValue)    var includeWalk = true
    @AppStorage(AppStorageKeys.includeSurvey.rawValue)  var includeSurvey = true

    @State private var showingClears = false

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
                    EmailFormView(title: "Email",
                                  address: $email)
                    //                            .border(.blue)
                }
                Section("Collected Data") {
                    NavigationLink("Clear Data", // isActive: $showingClears,
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
