//
//  Better_StepApp.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/19/21.
//

import SwiftUI


// MARK: - @AppStorage
enum AppStorageKeys: String {
    case walkInMinutes
    case reportAsMagnitude
    case reportingEmail

    case subjectID      // Is the right place?
    // We'd rather set it each time, right?
    // FIXME: Clear subjectID when transmitted
}


// TODO: report contents shouldn't be global
//       I guess they're not, since we could impose
//       an environmentObject at a lower level
//       of the hierarchy.

// MARK: - App struct
@main
struct Better_StepApp: App {

    @AppStorage(AppStorageKeys.subjectID.rawValue) var subjectID = ""

    var setupEnvironment: Configurations {
        Configurations(startingEmail: "Joe@user.net", duration: 2)
    }

    // FIXME: Draw this from the settings.
    //        AppStorage for subject ID and duration.
    static var commonReport = DASIReportContents()

    var body: some Scene {
        WindowGroup {
            TabView {

                // MARK: - DASI
                SurveyView()
                    .environmentObject(Self.commonReport)
                    .tabItem {
                        Image(systemName: "checkmark.square")
                        Text("Survey")
                    }

                // MARK: - Timed Walk
                WalkView()
                    .environmentObject(Self.commonReport)
                    .tabItem {
                        Image(systemName: "figure.walk")
                        Text("Walk")
                    }

                // MARK: - Reporting
                Text("Reporting Tab")
                    .environmentObject(Self.commonReport)
                    .tabItem {
                        Image(systemName: "doc.text")
                        Text("Report")
                    }

                // MARK: - Setup
                SetupView()
                    .environmentObject(
                        self.setupEnvironment
                    )
                    .environmentObject(Self.commonReport)
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Setup")
                    }
            }
        }

    }
}


