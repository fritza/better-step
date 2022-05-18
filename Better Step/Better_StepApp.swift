//
//  Better_StepApp.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/19/21.
//

import SwiftUI
import Combine


// TODO: report contents shouldn't be global
//       I guess they're not, since we could impose
//       an environmentObject at a lower level
//       of the hierarchy.

// MARK: - App struct
@main
struct Better_StepApp: App {
    // TODO: Better Step: Interpose the onboard sheet
    //       See Async_AccelApp.
    @ObservedObject var aStage = AppStage.shared

    @AppStorage(AppStorageKeys.includeWalk.rawValue)    var includeWalkPersistent = true
    @AppStorage(AppStorageKeys.includeDASISurvey.rawValue)  var includeDASIPersistent = true

    @StateObject var subjectID        = SubjectID()
    @StateObject var dasiPages        = DASIPages()
    @StateObject var dasiResponseList = DASIResponseList()
    @StateObject var phaseManager     = PhaseManager()
    @StateObject var fileCoordinator  = PerSubjectFileCoordinator()
    @StateObject var appStage         = AppStageState()


    #warning("Using currentSelection to rebuild the Tabs means end of the DASI Completion forces the phase back to its beginning.")
    var body: some Scene {
        WindowGroup {
            TabView(
                selection:
                    $aStage.currentSelection
            ) {
                // MARK: - DASI
                if includeDASIPersistent {
                    SurveyContainerView()
                        .badge(AppStages
                            .dasi.tabBadge)
                        .tabItem {
                            Image(systemName: AppStages.dasi.imageName)
                            Text(AppStages.dasi.visibleName)
                        }
                        .tag(AppStages.dasi)
                }

                // MARK: - Timed Walk
                if includeWalkPersistent {
                    WalkView()
                    // TODO: Add walk-related environmentObjects as soon as known.
                        .badge(AppStages.walk.tabBadge)
                        .tabItem {
                            Image(systemName: AppStages.walk.imageName)
                            Text(AppStages.walk.visibleName)
                        }
                        .tag(AppStages.walk)
                }

                // MARK: - Reporting
                // TODO: Add report-related environmentObjects as soon as known.
                Text("Reporting Tab")
                    .badge(AppStages.report.tabBadge)
                    .tabItem {
                        Image(systemName: AppStages.report.imageName)
                        Text(AppStages.report.visibleName)
                    }
                    .tag(AppStages.report)

                // MARK: - Setup
                SetupView()
                // TODO: Add configuration-related environmentObjects as soon as known.
                    .tabItem {
                        Image(systemName: AppStages.configuration.imageName)
                        Text(AppStages.configuration.visibleName)
                    }
                    .tag(AppStages.configuration)
            }
            .environmentObject(subjectID)
            .environmentObject(dasiPages)
            .environmentObject(dasiResponseList)
            .environmentObject(phaseManager)
            .environmentObject(fileCoordinator)
            .environmentObject(appStage)
            .environmentObject(WalkingSequence())
        }
    }
}
