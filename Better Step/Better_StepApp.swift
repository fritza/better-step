//
//  Better_StepApp.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/19/21.
//

import SwiftUI
import Combine

enum Constants {
#if DEBUG
    static let countdownDuration    = 15.0
#else
    static let countdownDuration    = 120.0
#endif

    static let countdownInterval    = 30
    static let sweepDuration        = 5.0
}


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

//    @AppStorage(AppStorageKeys.includeWalk.rawValue)        var includeWalkPersistent = true
//    @AppStorage(AppStorageKeys.includeDASISurvey.rawValue)  var includeDASIPersistent = true
//    @AppStorage(AppStorageKeys.inspectionMode.rawValue)     var perStagePresentation  = false

    @AppStorage(AppStorageKeys.collectedDASI.rawValue)
    var temporaryDASIStorage: String = ""
    @AppStorage(AppStorageKeys.collectedUsability.rawValue)
    var temporaryUsabilityStorage: String = ""

    @StateObject var dasiPages        = DASIPages()
    @StateObject var dasiResponseList = DASIResponseList()
    //    @StateObject var usabilityResponses = SurveyResponses()
    @StateObject var phaseManager     = PhaseManager()
    @StateObject var fileCoordinator  = PerSubjectFileCoordinator()
    @StateObject var appStage         = BSTAppStageState()


#warning("Using currentSelection to rebuild the Tabs means end of the DASI Completion forces the phase back to its beginning.")
    var body: some Scene {
        WindowGroup {
#if false
            TopContainerView()
#elseif true
            SurveyContainerView(completion: {
                result in
                if let answerList = try? result.get() {
                    // Save the answer list.
                    temporaryDASIStorage = answerList.csvLine!
                }
            })
            .environmentObject(DASIPages())
            .environmentObject(DASIResponseList())

#else
            TabView(
                selection:
                    $aStage.currentSelection
            ) {
                // MARK: - DASI
                if includeDASIPersistent {
                    SurveyContainerView()
                        .badge(BSTAppStages
                            .dasi.tabBadge)
                        .tabItem {
                            Image(systemName: BSTAppStages.dasi.imageName)
                            Text(BSTAppStages.dasi.visibleName)
                        }
                        .tag(BSTAppStages.dasi)
                }
                
                // MARK: - Timed Walk
                if includeWalkPersistent {
                    WalkView()
                    // TODO: Add walk-related environmentObjects as soon as known.
                        .badge(BSTAppStages.walk.tabBadge)
                        .tabItem {
                            Image(systemName: BSTAppStages.walk.imageName)
                            Text(BSTAppStages.walk.visibleName)
                        }
                        .tag(BSTAppStages.walk)
                }
                
                // MARK: - Reporting
                // TODO: Add report-related environmentObjects as soon as known.
                Text("Reporting Tab")
                    .badge(BSTAppStages.report.tabBadge)
                    .tabItem {
                        Image(systemName: BSTAppStages.report.imageName)
                        Text(BSTAppStages.report.visibleName)
                    }
                    .tag(BSTAppStages.report)
                
                // MARK: - Setup
                SetupView()
                // TODO: Add configuration-related environmentObjects as soon as known.
                    .tabItem {
                        Image(systemName: BSTAppStages.configuration.imageName)
                        Text(BSTAppStages.configuration.visibleName)
                    }
                    .tag(BSTAppStages.configuration)
            }
            .environmentObject(dasiPages)
            .environmentObject(dasiResponseList)
            .environmentObject(SurveyResponses())   // FIXME: Load these for restoration
            .environmentObject(fileCoordinator)
            .environmentObject(appStage)
            .environmentObject(WalkingSequence())
            .environmentObject(phaseManager)
#endif
        }
    }
}
