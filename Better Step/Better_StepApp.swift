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
            TopContainerView()

//            NavigationView {
//                SurveyContainerView { result in
//                    do {
//                        let list = try result.get()
//                        print("Survey returned:", list.csvLine)
//                    }
//                    catch {
//                        print("Survey returned error", error)
//                    }
//                }
//            }
        }
    }
}
