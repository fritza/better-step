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

/*
 For deciding whether to drop the SubjectIDSheetView:
 Just keep the subjectID in Defaults.
 The binding on whether to show the sheet could then be subjectID default = nil or empty
 Don't allow the sheet to cancel/revert
 The sheet holds off until accepted to transfer the value, because otherwise it just rolls up.
 Or maybe just dismiss().
 How do you reset the subject ID? Clear-ID button in Settings. If you have a wrong subject ID you want to replace, then ipso facto you aren't blocked by a sheet.
 Bothersome Scenario:
    The user does a clear-ID
    The ID is cleared.
    The sheet is then signaled to drop, right?
        is this a problem? It does violate
        stability: It's surprising that the settings should be shuttered just by hitting "clear."
        safety/forgiveness: User loses sight of the Settings page (with no clue how to regain it)
            Are all the others applied? Reverted?
 So the guiding principle is that nothing happens, including/especially clears, until the user is done with the settings page entirely, and expresses the desire to do so. I think "expresses the desire" means leaving the tab.
 */

@main
struct Async_AccelApp: App {
    @AppStorage(AppStorageKeys.includeWalk.rawValue) var includeWalk: Bool = true
    @AppStorage(AppStorageKeys.includeSurvey.rawValue) var includeSurvey: Bool = true

    @State var shouldShowSheet: Bool = true // SubjectID.shared.noSubjectID
    @State var selectedTab: Int = 1

    func badgeText(representing stage: AppStages) -> String? {
        return PhaseManager.shared.isCompleted(stage) ?  "✓" : nil
    }

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                if includeSurvey {
                    SurveyContainerView()
                    // FIXME: Make the completion check responsive
                        .badge(badgeText(representing: .dasi))
                        .tabItem {
                            Label("Survey",
                                  systemImage: "person.crop.circle.badge.questionmark")
                        }
                        .tag(4)
                }
                // FIXME: Get symbolic tab tag IDs.
                if includeWalk {
                    ContentView()
                        .badge(badgeText(representing: .walk))
                        .tabItem {
                            Label("Accelerometry",
                                  systemImage: "arrow.triangle.swap")
                        }
                        .tag(1)
                }

                ReportingView()
                    .tabItem {
                        Label("Reporting", systemImage: "envelope")
                    }
                    .tag(2)

                Setup()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(3)

                WalkInstructionBase()
                    .tabItem {
                        Label("Intro", systemImage: "person.crop.circle.badge.questionmark")
                    }
                    .tag(5)
            }
            .sheet(isPresented: $shouldShowSheet) {
                SubjectIDSheetView(originalID: SubjectID.shared.unwrappedSubjectID)
            }
            .environmentObject(SubjectID.shared)
            .environmentObject(DASIPages())
            .environmentObject(DASIResponseList())
            .environmentObject(PhaseManager.shared)
        }
    }
}
