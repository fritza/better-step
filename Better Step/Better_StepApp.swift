//
//  Better_StepApp.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/19/21.
//

import SwiftUI
import Combine

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
    @ObservedObject var aStage = AppStage.shared


    #warning("Using currentSelection to rebuild the Tabs means end of the DASI Completion forces the phase back to its beginning.")
    var body: some Scene {
        WindowGroup {
            TabView {

                // MARK: - DASI
                SurveyContainerView()
                    .environmentObject(DASIResponses())
                    .environmentObject(DASIPages(.landing))
                    .badge(AppStages.dasi.tabBadge)
                    .tabItem {
                        Image(systemName: AppStages.dasi.imageName)
                        Text(AppStages.dasi.visibleName)
                    }
                    .tag(AppStages.dasi)

                // MARK: - Timed Walk
                WalkView()
                    .badge(AppStages.walk.tabBadge)
                    .tabItem {
                        Image(systemName: AppStages.walk.imageName)
                        Text(AppStages.walk.visibleName)
                    }
                    .tag(AppStages.walk)

                // MARK: - Reporting
                Text("Reporting Tab")
                    .badge(AppStages.report.tabBadge)
                    .tabItem {
                        Image(systemName: AppStages.report.imageName)
                        Text(AppStages.report.visibleName)
                    }
                    .tag(AppStages.report)

                // MARK: - Setup
                SetupView()
                    .tabItem {
                        Image(systemName: AppStages.configuration.imageName)
                        Text(AppStages.configuration.visibleName)
                    }
                    .tag(AppStages.configuration)
            }
            .environmentObject(globals)
            .environmentObject(RootState.shared)
        }
    }
}

// FIXME: A watcher of AppStage.shared could trigger report generation


