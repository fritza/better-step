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

    static let dasiWalkRange = (1...10)
}


// TODO: report contents shouldn't be global
//       I guess they're not, since we could impose
//       an environmentObject at a lower level
//       of the hierarchy.

// MARK: - App struct
@main
struct Better_StepApp: App {

    @AppStorage(AppStorageKeys.subjectID.rawValue) var subjectID = ""
    let globals = GlobalState()

    var body: some Scene {
        WindowGroup {
            TabView {

                // MARK: - DASI
                SurveyContainerView()
                    .environmentObject(DASIReportContents())
                    .environmentObject(DASIContentState(.landing))
                    .tabItem {
                        Image(systemName: "checkmark.square")
                        Text("Survey")
                    }


                // MARK: - Timed Walk
                WalkView()
                    .tabItem {
                        Image(systemName: "figure.walk")
                        Text("Walk")
                    }

                // MARK: - Reporting
                Text("Reporting Tab")
                    .tabItem {
                        Image(systemName: "doc.text")
                        Text("Report")
                    }

                // MARK: - Setup
                SetupView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Setup")
                    }
            }
            .environmentObject(globals)
        }


    }
}


