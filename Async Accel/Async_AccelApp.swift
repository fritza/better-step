//
//  Async_AccelApp.swift
//  Async Accel
//
//  Created by Fritz Anderson on 3/10/22.
//

import SwiftUI

/*
 Initialization chain


 AcceleratorFileSink depends on PerSubjectFileCoordinator

 PerUserSubjectCoordinator (.shared) depends on Subject ID
    It must await a non-nil Subject ID
    Is it a problem that SubjectID is an @EnvironmentObject?

 Subject ID depends on
    being nil if unknown
    set by SubjectIDSheetView
    retrieved by UserDefaults (having previously been set by SubjectIDSheetView)

 _Changing_ Subject ID invalidates
    Subject ID -> PerUserSubjectCoordinator -> AcceleratorFileSink
 */

@main
struct Async_AccelApp: App {
    @State var shouldShowSheet: Bool = true // SubjectID.shared.noSubjectID
    var body: some Scene {
        WindowGroup {
            ContentView()
                .sheet(isPresented: $shouldShowSheet) {
                    SubjectIDSheetView(originalID: SubjectID.shared.unwrappedSubjectID)
                }
                .environmentObject(SubjectID.shared)
        }
    }
}
