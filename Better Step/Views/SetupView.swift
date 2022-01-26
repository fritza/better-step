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
//    @Published var emailAddress: String
//    @Published var durationInMinutes: Int

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

struct SetupView: View {
    // FIXME: text field row can't track focus.

    @FocusState private var controlFocus: ControlFocus?

    @AppStorage(AppStorageKeys.reportAsMagnitude.rawValue) var asMagnitude = false
    @AppStorage(AppStorageKeys.walkInMinutes.rawValue) var duration = 6
    @AppStorage(AppStorageKeys.reportingEmail.rawValue) var email = ""

    var body: some View {
        NavigationView {
//            VStack {
                Form {
                    Section("Walk") {
                        Stepper("Duration (\(self.duration)):",
                                value: $duration,
                                in: AppStorageKeys.dasiWalkRange,
                                step: 1,
                                onEditingChanged: { _ in
                            controlFocus = nil
                        })

                    }
                    Section("Reporting") {
                        Toggle("Report magnitude",
                               isOn: $asMagnitude)
                        // FIXME: need a binding for the email
                        EmailFormView(title: "Email",
                                      address: $email)
//                            .border(.blue)
                    }
                }
//            }
            .navigationTitle("Configuration")
//            .padding()
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
