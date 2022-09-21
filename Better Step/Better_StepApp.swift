//
//  Better_StepApp.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/19/21.
//

import SwiftUI
import Combine

// MARK: - App struct
@main
struct Better_StepApp: App {
    @ObservedObject var aStage = AppStage.shared

    @AppStorage(AppStorageKeys.collectedDASI.rawValue) var collectedDASI: Bool = false
    @AppStorage(AppStorageKeys.collectedUsability.rawValue) var collectedUsability: Bool = false


    @StateObject var dasiPages        = DASIPages()
    @StateObject var dasiResponseList = DASIResponseList()
    //    @StateObject var usabilityResponses = SurveyResponses()
    @StateObject var phaseManager     = PhaseManager()
    @StateObject var fileCoordinator  = PerSubjectFileCoordinator()
    @StateObject var appStage         = BSTAppStageState()


#warning("Using currentSelection to rebuild the Tabs means end of the DASI Completion forces the phase back to its beginning.")

 //   @State var currentPhase: TopPhases? = .walking

    var body: some Scene {
        WindowGroup {
#if true
//            WalkingContainerView() {
//                (results: WalkingContainerView.ResultValue) -> Void in
//            }
            NavigationView {
                SweepSecondView(duration: 10, onCompletion: {
                    print("ss complete")
                })
                .navigationTitle("Walking")
                .padding()
            }
            //                .reversionToolbar($showRewindAlert)
#elseif false
            TopContainerView()
#elseif false
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
                WalkingContainerView()
                // TODO: Add walk-related environmentObjects as soon as known.
                    .badge(BSTAppStages.walk.tabBadge)
                    .tabItem {
                        Image(systemName: BSTAppStages.walk.imageName)
                        Text(BSTAppStages.walk.visibleName)
                    }
                    .tag(BSTAppStages.walk)

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
