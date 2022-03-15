//
//  Better_StepApp.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/19/21.
//

import SwiftUI


// MARK: - @AppStorage
enum AppStorageKeys: String {
    /// How long the timed walk is to last, in _minutes,_ e.g. 6.
    case walkInMinutes
    /// The frequency in Hertz (e.g. 120) for sampling the accelerometer.
    case walkSamplingRate
    /// If `false`, report acceleration in three axes; otherwise as the vector magnitude.
    case reportAsMagnitude
    /// The email address to receive report archive files.
    case reportingEmail
    /// Whether to include the timed walk
    case includeWalk
    /// Whether to include the DASI survey
    case includeSurvey
    /// The last known subject ID.
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

    // FIXME: App does not interpose the app onboard sheet.
    @AppStorage(AppStorageKeys.subjectID.rawValue) var subjectID = ""
    let globals = ApplicationState()

    var body: some Scene {
        WindowGroup {
            TabView {

                // MARK: - DASI
                SurveyContainerView()
                    .environmentObject(DASIResponses())
                    .environmentObject(DASIPages(.landing))
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


