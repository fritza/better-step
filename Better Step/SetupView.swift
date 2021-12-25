//
//  SetupView.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/19/21.
//

import SwiftUI

final class Configurations: ObservableObject, CustomStringConvertible {
    @Published var emailAddress: String
    @Published var durationInMinutes: Int

    static let durationRange = (1...10)

    var description: String {
        let emailString = emailAddress
        let durationString = String(describing: durationInMinutes)
       return "Configurations(email: \(emailString), duration: \(durationString))"
    }

    init(startingEmail: String, duration: Int) {
        emailAddress = startingEmail
        durationInMinutes = duration
    }
}

private enum ControlFocus: String {
    case emailField
    case durationStepper
}


struct SetupView: View {
    @EnvironmentObject var config: Configurations
    @FocusState private var controlFocus: ControlFocus?

    var body: some View {
        NavigationView {
            Form {
                Section("All of them") {
                    Stepper("Duration (\(config.durationInMinutes)):",
                            value: $config.durationInMinutes,
                            in: Configurations.durationRange,
                            step: 1)
                        .focused($controlFocus, equals: .durationStepper)

                    HStack {
                        Text("Email:")
                        HStack {
                            TextField("IGNORED 1",
                                      text: $config.emailAddress,
                                      prompt: Text("reporting address"))
                                .onSubmit(of: .text) {
                                    // Some kind of update.
                                }
                            Button(action: { config.emailAddress = "" }) {
                                Image(systemName: "multiply.circle.fill")
                                    .renderingMode(.template)
                                    .foregroundColor(.gray)
                                    .opacity(0.5)
                            }
                            .padding([.trailing], 0)
                        }
                        .focused($controlFocus, equals: .emailField)

                    }
//                    .keyboardType(.emailAddress)

                }
            }
            .navigationTitle("Configuration")
            .padding()
        }
    }
}

struct SetupView_Previews: PreviewProvider {
    static let config: Configurations = {
        return Configurations(startingEmail: "", duration: 9)
    }()

    static var previews: some View {
        VStack {
            SetupView()
                .environmentObject(config)
                .frame(height: .infinity)
        }
    }
}
