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
//    @ObservedObject var aStage = AppStage.shared

    @AppStorage(AppStorageKeys.collectedDASI.rawValue) var collectedDASI: Bool = false
    @AppStorage(AppStorageKeys.collectedUsability.rawValue) var collectedUsability: Bool = false


    #warning("Add a DASI container.")
    // Provide for its reading/writing responses in App Storage? As I recall, Dan would like those results to cohabit with Usability.
    // Isn't there a can-advance/completed handler that responds to both DASI and usability being complete?

    // FIXME: DASIPageSelection and DASIResponseList -> DASI container.
//    @StateObject var dasiPages        = DASIPageSelection()
//    @StateObject var dasiResponseList = DASIResponseList()

    var body: some Scene {
        WindowGroup {

#if false
            TopContainerView()

#elseif true
            NavigationView<WalkingContainerView> {
                WalkingContainerView { _ in
                }
            }
            .environmentObject(MotionManager(phase: .walk_1))
#elseif false
            NavigationView {
                SweepSecondView(duration: 10, onCompletion: {
                    print("ss complete")
                })
                .navigationTitle("Walking")
                .padding()
            }
            //                .reversionToolbar($showRewindAlert)
#elseif false
            SurveyContainerView(completion: {
                result in
                if let answerList = try? result.get() {
                    // Save the answer list.
                    temporaryDASIStorage = answerList.csvLine!
                }
            })
//            .environmentObject(DASIPageSelection())
//            .environmentObject(DASIResponseList())

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
//            .environmentObject(fileCoordinator)
            .environmentObject(appStage)
            .environmentObject(WalkingSequence())
            .environmentObject(phaseManager)

            #warning("Move MotionManager environment var closer to the walk container")
            .environmentObject(MotionManager(phase: .walk_1))
#endif
        }
    }
}
