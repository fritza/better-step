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
    @AppStorage(ASKeys.collectedDASI.rawValue) var collectedDASI: Bool = false
    @AppStorage(ASKeys.collectedUsability.rawValue) var collectedUsability: Bool = false
    @AppStorage(ASKeys.hasCompletedSurveys.rawValue)  var hasCompletedSurveys : Bool = true

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
            // TODO: remove some of these #cases.
            // TODO: Respond to the per-task deletion notifications

            TopContainerView()
                .environmentObject(NotificationSetup())
            //                .environmentObject(DASIResponseList())
        }
    }
}
