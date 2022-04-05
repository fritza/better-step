//
//  Setup.swift
//  Async Accel
//
//  Created by Fritz Anderson on 4/1/22.
//

import SwiftUI

/// Display and edit settings for things like whether major phases (walking, DASI) should be exposed, email address, walk time limit, etc.
///
/// The nomenclature on settings values is:
/// * `~Persistent`:  The global value of the setting, usually maintained as `$AppStorage`.
/// * `~Displayed`: The working value for the setting as tracked from the UI
/// * `~Key`: The `UserDefaults` key for persisting the value
///
/// Upon `accept()`, the `Displayed` values get transferred to the `Persistent` (`UserDefaults`) `var`s. Upon `revert()` the working (`Displayed`) values are reloaded from the persistent ones.

struct Setup: View {
    /// The `UserDefaults`/`@AppStorage` key for whether the DASI survey should be available. The purpose of these `~Key` constants is to provide shorter names than through `AppStorageKeys`.
    static let includeDASIKey = AppStorageKeys.includeSurvey.rawValue
    /// See comment for `includeDASIKey` for explanation
    static let includeWalkKey = AppStorageKeys.includeWalk.rawValue
    /// See comment for `includeDASIKey` for explanation
    static let durationKey    = AppStorageKeys.walkInMinutes.rawValue
    /// See comment for `includeDASIKey` for explanation
    static let magnitudeKey   = AppStorageKeys.reportAsMagnitude.rawValue
    /// See comment for `includeDASIKey` for explanation
    static let emailKey       = AppStorageKeys.reportingEmail.rawValue

    // MARK: Include/Display values
    @AppStorage(includeWalkKey)    var includeWalkPersistent = true
    @State private var includeDASIDisplayed = true

    @AppStorage(includeDASIKey) var includeDASIPersistent = true
    @State private var includeWalkDisplayed = true

    @AppStorage(durationKey)  var durationPersistent = 6
    @State private var durationDisplayed: Int

    @AppStorage(magnitudeKey) var magnitudePersistent = true
    @State private var magnitudeDisplayed = true

    @AppStorage(Self.emailKey) var emailPersistent = "example@example.edu"
    @State private var emailDisplayed = "example@example.edu"

    var neitherPhaseActive: Bool { !includeWalkDisplayed && !includeDASIDisplayed }

    init() {
        // FIXME: The @AppStorage has no effect?
        //        Changes made in _the active canvas_ don't
        //        survive the round trip through the
        //        passive canvas.
        let defaults = UserDefaults.standard
        includeWalkDisplayed = defaults.bool(forKey: Self.includeDASIKey)
        includeWalkDisplayed = defaults.bool(
            forKey: Self.includeWalkKey)
        durationDisplayed    = defaults.integer(
            forKey: Self.durationKey)
        magnitudeDisplayed   = defaults.bool(
            forKey: Self.magnitudeKey)
        emailDisplayed       = defaults.string(forKey: Self.emailKey) ?? "example@example.edu"
    }

    func accept() {
        includeDASIPersistent = includeDASIDisplayed
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

    var dasiSection: some View {
        Section("DASI") {
            Toggle("Perform Survey"  + (neitherPhaseActive ? " ⚠️" : ""),
                   isOn: $includeDASIDisplayed)
        }
    }

    var resetSection: some View {
        Section("Data") {
            NavigationLink("Clear data") {
                Text("The clear-items buttons")
            }
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
                dasiSection
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
                resetSection
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
