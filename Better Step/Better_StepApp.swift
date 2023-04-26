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
    let contentArray = try! CardContent.contentArray(from: ["walk-intro"])
    
    
    var body: some Scene {
        WindowGroup {
/*
            switch IsolationModes.isolation {
            case .dasi:
                SurveyContainerView { result in
                    guard let report = try? result.get() else {
                        IsolationModes.stringResult = nil
                        return
                    }
                    IsolationModes.stringResult = report.csvLine
                }

            case .usability:
                UsabilityContainer { stringResult in
                    guard let report = try? stringResult.get() else {
                        IsolationModes.stringResult = nil
                        return
                    }
                    IsolationModes.stringResult = report
                }
            default:
 */
                TopContainerView()
//            }
        }
    }
}
