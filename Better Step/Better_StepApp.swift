//
//  Better_StepApp.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/19/21.
//

import SwiftUI

@main
struct Better_StepApp: App {
    var setupEnvironment: Configurations {
        Configurations(startingEmail: "Joe@user.net", duration: 2)
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                SurveyView()
                    .tabItem {
                        Image(systemName: "checkmark.square")
                        Text("Survey")
                    }
                WalkView()
                    .tabItem {
                        Image(systemName: "figure.walk")
                        Text("Walk")
                    }
                Text("Reporting Tab")
                    .tabItem {
                        Image(systemName: "doc.text")
                        Text("Report")
                    }
                SetupView()
                    .environmentObject(
                        self.setupEnvironment
//                        Configurations(startingEmail: "fritza@mac.com", duration: 6)
                    )
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Setup")
                    }
            }
            .font(.headline)
        }
    }
}


