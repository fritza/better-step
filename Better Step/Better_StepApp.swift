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
    @AppStorage(AppStorageKeys.hasNeverCompleted.rawValue)  var hasNeverCompleted : Bool = true

    @State var shouldWarnOfReversion : Bool = false


#warning("Add a DASI container.")
    // Provide for its reading/writing responses in App Storage? As I recall, Dan would like those results to cohabit with Usability.
    // Isn't there a can-advance/completed handler that responds to both DASI and usability being complete?

    // FIXME: DASIPageSelection and DASIResponseList -> DASI container.
    //    @StateObject var dasiPages        = DASIPageSelection()
    //    @StateObject var dasiResponseList = DASIResponseList()

    static func onboardInfo() -> TaskInterstitialDecodable {
        do {
            guard let url = Bundle.main.url(forResource: "onboard-intro", withExtension: "json") else {
                throw FileStorageErrors.cantFindURL(#function)
            }
            let jsonData = try Data(contentsOf: url)
            let rawList = try JSONDecoder()
                .decode([TaskInterstitialDecodable].self,
                        from: jsonData)
            return rawList.first!
        }
        catch {
            print("Bad decoding:", error)
            fatalError("trying to decode \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
#if false
//            TopContainerView()

#elseif false
            NavigationView<WalkingContainerView> {
                WalkingContainerView { _ in
                }
            }
            .environmentObject(MotionManager(phase: .walk_1))
#elseif true
            /*
             Tuesday 1-5
             */
//            NavigationView {
                OnboardContainerView() { result in
                    if let newID = try? result.get() {
                        print("Returned", newID)
                    }
                    else {
                        print("Got no result.")
                    }
                }
//            }
            //                .frame(width: 800)//, height: 300)
            .padding()
        //            .reversionToolbar($shouldWarnOfReversion)
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
