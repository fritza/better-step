//
//  ToolbarViewModifiers.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/14/22.
//

import SwiftUI

struct ReversionAlert: ViewModifier {
    @AppStorage(AppStorageKeys.subjectID.rawValue)
    var subjectID: String = ""
    @AppStorage(AppStorageKeys.collectedDASI.rawValue)
    var collectedDASI: Bool = false
    @AppStorage(AppStorageKeys.collectedUsability.rawValue)
    var collectedUsability: Bool = false

    @Binding var nextPhase: TopPhases?
    @Binding var shouldShow: Bool

    init(next: Binding<TopPhases?>, show: Binding<Bool>) {
        _nextPhase = next
        _shouldShow = show
    }

    func body(content: Content) -> some View {
        content
            .alert("Starting Over", isPresented: $shouldShow) {
                Button("Reset" , role: .destructive) {
                    // Forget user and progress
                    subjectID = ""
                    collectedDASI = false
                    collectedUsability = false
                    nextPhase = .onboarding
                }
                Button("Rewind") {
                    // The user and progress are ok,
                    // just wind back to the first screen
                    nextPhase = .onboarding
                }
            }
        message: {
            Text("Do you want to rewind (restart as the same subject), or reset (restart with user and progress cleared)?\nYou cannot undo this.") }
    }
}

struct ReversionToolbar: ViewModifier {
    @Binding var shouldShow: Bool

    init(_ show: Binding<Bool>) {
        _shouldShow = show
    }
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button()
                    { shouldShow = true }
                label: {
                    Label("configure", systemImage: "gear")
                }
                }
            }
            .navigationBarBackButtonHidden(true)
    }
}

extension View {
    func reversionToolbar(_ show: Binding<Bool>) -> some View {
        modifier(ReversionToolbar(show))
    }

    func reversionAlert(next: Binding<TopPhases?>, shouldShow: Binding<Bool>) -> some View {
        modifier(ReversionAlert(next: next, show: shouldShow))
    }
}

