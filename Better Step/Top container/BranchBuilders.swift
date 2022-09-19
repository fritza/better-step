//
//  BranchBuilders.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/14/22.
//

import SwiftUI
import CoreMotion

// MARK: - Branch links
extension TopContainerView {
    /// **Top-level** view for the greeting/onboarding phase
    ///
    /// At first effort, there is only one stage, a greeting. In future it may have alternative directions for introduction and re-entry.
    @ViewBuilder func onboarding_view() -> some View {
        // MARK: Onboarding
        NavigationLink(
            "SHOULDN'T SEE (onboarding_view)",
            tag: TopPhases.onboarding, selection: $currentPhase) {
                ApplicationOnboardView() { result in
                    guard let newID = try? result.get() else { self.currentPhase = .failed; return }
                    currentPhase = .walking
                    SubjectID.id = newID
                    assert(SubjectID.id == newID)
                }!
                .reversionToolbar($showRewindAlert)
                .navigationTitle("Welcome")
                .padding()
            }
            .hidden()
    }

    /// **Top-level** view for the walkiing phase.
    ///
    /// The phase controller handles the stages (intro, walk 1, intertitial, walk 2, exit).
    @ViewBuilder func walking_view() -> some View {
        // MARK: Walking
        NavigationLink(
            "SHOULDN'T SEE (walking_view)",
            tag: TopPhases.walking, selection: $currentPhase) {
                DummyWalk { result in
                    guard let series = try? result.get() else {
                        self.currentPhase = .failed; return
                    }
                    let nextPhase: TopPhases
                    switch (d: collectedDASI, u: collectedUsability) {
                    case (d: false, u: _):
                        // no DASI, get DASI
                        nextPhase = .dasi
                    case (d: true, u: false):
                        // dasi, no usability, get usability
                        nextPhase = .usability
                    case (d: true, u: true):
                        // dasi, usability, go comclusion
                        nextPhase = .conclusion
                    }
                    self.currentPhase = nextPhase
                }
                Text("walking phase")
                    .navigationTitle("Walking")
                    .padding()
                    .reversionToolbar($showRewindAlert)
            }
            .hidden()
    }

    /// **Top-level** view for the DASI-survey phase
    @ViewBuilder func dasi_view() -> some View {
        NavigationLink(
            "SHOULDN'T SEE (dasi_view)",
            tag: TopPhases.dasi, selection: $currentPhase) {
                SurveyContainerView(completion: {
                    result in
                    if let answerList = try? result.get() {
                        // Save the answer list.
                        let surveyContents = answerList.csvLine!
                        print()
                    }
                })
                .navigationTitle("(not) DASI")
                .reversionToolbar($showRewindAlert)
                .padding()
            }
            .hidden()
        // No reversion from DASI to walking
    }

    /// **Top-level** view for the usability phase
    ///
    /// The phase controller handles the stages (rating sequence, details).
    @ViewBuilder func usability_view() -> some View {
        // MARK: Usability
        NavigationLink(
            "SHOULDN'T SEE (usability_view)",
            tag: TopPhases.usability, selection: $currentPhase) {
                DummyUsability { result in
                    guard let pair = try? result.get() else { self.currentPhase = .failed; return}
                    print("Selections:", pair.0,
                          "Answers:"   , pair.1)

                    self.currentPhase = collectedDASI ? .conclusion : .dasi
                    self.collectedUsability = true
                }
                .navigationTitle("Usability")
                .padding()
                .reversionToolbar($showRewindAlert)
            }
            .hidden()
    }

    @ViewBuilder func conclusion_view() -> some View {
        NavigationLink(
            "SHOULDN'T SEE (conclusion_view)",
            tag: TopPhases.conclusion, selection: $currentPhase) {
                DummyConclusion { _ in
                    self.currentPhase = .failed
                }
                .navigationTitle("Finished")
                .reversionToolbar($showRewindAlert)
            }
            .hidden()
    }

    @ViewBuilder func failed_view() -> some View
    {
        // MARK: Failed
        NavigationLink(
            "SHOULDN'T SEE (failed_view)",
            tag: TopPhases.failed, selection: $currentPhase) {
                DummyFailure { _ in
                    self.currentPhase = .failed
                }
                .reversionToolbar($showRewindAlert)
                .navigationTitle("FAILED")
                .padding()
            }
            .hidden()
    }
}
