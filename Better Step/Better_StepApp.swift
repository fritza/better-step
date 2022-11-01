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

#elseif true
            // TODO: remove some of these #cases.
            // TODO: Respond to the per-task deletion notifications

        TopContainerView()
            .environmentObject(NotificationSetup())
        //                .environmentObject(DASIResponseList())
#endif
        }
    }
}
