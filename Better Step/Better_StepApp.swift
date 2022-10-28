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
    @AppStorage(AppStorageKeys.collectedDASI.rawValue) var collectedDASI: Bool = false
    @AppStorage(AppStorageKeys.collectedUsability.rawValue) var collectedUsability: Bool = false
    @AppStorage(AppStorageKeys.hasCompletedSurveys.rawValue)  var hasCompletedSurveys : Bool = true

    @State var shouldWarnOfReversion : Bool = false

    // WARNIING: This DASIPageSelection shouldn't have to be
    // so low in the hierarchy. However, the DASI stack adamantly failed
    // to find what I believe to have been a propertly-set instance.
    //
    // Doesn't work here. Moving the creation and environmentObject()
    // to a static in TopContainerView.
//    static let dasiPageSelection = DASIPageSelection(.landing)

    var body: some Scene {
        WindowGroup {
#if false
            NavigationView {
                WalkingContainerView {
                    response in print("Response =", response)
                }
            }
#elseif true
            NavigationView {
                UsabilityContainer { resultValue in
                    guard let array = try? resultValue.get() else {
                        print("UsabilityView should not fail.")
                        fatalError()
                    }

                    print("value for csv is",
                          array.map({ "\($0)" }).joined(separator: ","))
                }
            }
            .environment(\.symbolRenderingMode, .hierarchical)

            // TODO: Nav bars persisting -> EnvironmentObjects?

#elseif false
        TopContainerView()
            .environmentObject(NotificationSetup())
        //                .environmentObject(DASIResponseList())
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

            .environmentObject(appStage)
            .environmentObject(WalkingSequence())
            .environmentObject(phaseManager)

            .environmentObject(NotificationSetup())

#warning("Move MotionManager environment var closer to the walk container")
            .environmentObject(MotionManager(phase: .walk_1))
#endif
        }
    }
}
