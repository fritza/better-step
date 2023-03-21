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
    @State var shouldWarnOfReversion : Bool = false

    var body: some Scene {
        WindowGroup {
            TopContainerView()
        }
    }
}
