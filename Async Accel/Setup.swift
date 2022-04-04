//
//  Setup.swift
//  Async Accel
//
//  Created by Fritz Anderson on 4/1/22.
//

import SwiftUI


struct Setup: View {
    static let includeWalkKey = AppStorageKeys.includeWalk.rawValue
    static let durationKey    = AppStorageKeys.walkInMinutes.rawValue
    static let magnitudeKey   = AppStorageKeys.reportAsMagnitude.rawValue
    static let emailKey       = AppStorageKeys.reportingEmail.rawValue

    @AppStorage(includeWalkKey)    var includeWalkPersistent = true
    @State private var includeWalkDisplayed = true

    @AppStorage(durationKey)  var durationPersistent = 6
    @State private var durationDisplayed: Int

    @AppStorage(magnitudeKey) var magnitudePersistent = true
    @State private var magnitudeDisplayed = true

    @AppStorage(Self.emailKey) var emailPersistent = "example@example.edu"
    @State private var emailDisplayed = "example@example.edu"

    var neitherPhaseActive: Bool { !includeWalkDisplayed }

    init() {
        // FIXME: The @AppStorage has no effect?
        //        Changes made in _the active canvas_ don't
        //        survive the round trip through the
        //        passive canvas.
        let defaults = UserDefaults.standard
        includeWalkDisplayed = defaults.bool(
            forKey: Self.includeWalkKey)
        durationDisplayed    = defaults.integer(
            forKey: Self.durationKey)
        magnitudeDisplayed   = defaults.bool(
            forKey: Self.magnitudeKey)
        emailDisplayed       = defaults.string(forKey: Self.emailKey) ?? "example@example.edu"
    }

    func accept() {
        includeWalkPersistent = includeWalkDisplayed
        durationPersistent    = durationDisplayed
        magnitudePersistent   = magnitudeDisplayed
        emailPersistent       = emailDisplayed
    }

    func revert() {
        includeWalkDisplayed = includeWalkPersistent
        durationDisplayed    = durationPersistent
        magnitudeDisplayed   = magnitudePersistent
        emailDisplayed       = emailPersistent
    }


    var walkSection: some View {
        Section("Walk") {
            Toggle("Perform Timed Walk" + (neitherPhaseActive ? " ⚠️" : ""),
                   isOn: $includeWalkDisplayed)
            Stepper("Duration (\(self.durationDisplayed)):",
                    value: $durationDisplayed,
                    in: AppStorageKeys.dasiWalkRange,
                    step: 1,
                    onEditingChanged: { _ in
            })
        }
    }

    fileprivate func toolbarItem(id: String,
                                 location: ToolbarItemPlacement,
                                 action: @escaping () -> Void)
    -> ToolbarItem<String, Button<Text>> {
        return ToolbarItem(id: id,
                           placement: location, showsByDefault: true) {
            Button(id) { action() }
        }
    }

    var body: some View {
        NavigationView {
            Form {
                walkSection

                Section("Reporting") {
                    Toggle(
                        "Report as magnitude  —  "
                        + (magnitudeDisplayed ? "|a|" : " a⃑")
                        ,
                           isOn: $magnitudeDisplayed)
                    EmailFormView(
                        title: "Email:*",
                        address: $emailDisplayed)
                    Text("* demo purposes only").font(.caption)
                }
            }
            .navigationTitle("Configuration")
            .toolbar {
                toolbarItem(id: "Revert",
                            location: .navigationBarLeading) {
                    revert()
                }
                toolbarItem(id: "Apply",
                            location: .navigationBarTrailing) {
                    accept()
                }
            }
        }
    }
}

struct Setup_Previews: PreviewProvider {
    static var previews: some View {
        Setup()
    }
}
