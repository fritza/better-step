//
//  ToolbarViewModifiers.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/14/22.
//

import SwiftUI

struct ReversionAlert: ViewModifier {
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
                    nextPhase = .onboarding
                }
            }
        message: {
            Text("This button removes everything but the subject ID and starts over.") }
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

