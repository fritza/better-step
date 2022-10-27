//
//  TopPhaseBuilders.swift
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
                ApplicationOnboardView(string: $someStringOrOther) { result in
                    guard let newID = try? result.get() else {
                        self.currentFailingPhase = currentPhase
                        self.currentPhase = .failed
                        return
                    }
                    currentPhase = .walking
                    SubjectID.id = newID
                    assert(SubjectID.id == newID)
                }
//                .reversionToolbar($showRewindAlert)
                .navigationTitle("Welcome")
                .padding()
            }
            .hidden()
    }

    /// **Top-level** view for the walkiing phase.
    ///
    /// This phase controller also determines the successor to the walk.
    ///
    /// *  If DASI must still be done, go to DASI
    /// *  If Usability is still to be done, go Usability.
    /// * If neither, go to DASI
    /// * If both, go to conclusion.
    ///
    /// The phase controller handles the stages (intro, walk 1, intertitial, walk 2, exit).
    @ViewBuilder func walking_view() -> some View {
        // MARK: Walking
        NavigationLink ( //<WalkingContainerView, TopPhases>(
            "SHOULDN'T SEE (walking_view)",
            tag: TopPhases.walking, selection: $currentPhase, destination: {
                WalkingContainerView { error in
                    if let error {
                        // TODO: respond to cancellation."
                        print(#function,
                              "- WalkingContainerView came back with an error:",
                              error.localizedDescription)
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
                //                    .navigationTitle("Walking")
                .padding()
            })
        .hidden()
    }

    /// **Top-level** view for the DASI-survey phase
    @ViewBuilder func dasi_view() -> some View {
        NavigationLink(
            "SHOULDN'T SEE (dasi_view)",
            tag: TopPhases.dasi, selection: $currentPhase) {
#warning("Proceed to FailureView if result is failure")
                SurveyContainerView({


                    // This is a little high on the hierarchy
                    // (SurveyContainerView knows when to commit the data)
                    result in
                    if let answerList = try? result.get() {
                        // Save the answer list.
                        let surveyContents = answerList.csvLine!
                        print()

// FIXME: do something with the CSV line.
                        // TODO: Make next-phase and DASI flags dynamic
                        self.currentPhase = .conclusion // .usabilityForm
                        self.collectedDASI = true
                    }
                })
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
                UsabilityContainer { result in
                    guard let csv = try? result.get() else {
                        self.currentFailingPhase = TopPhases.usability
                        self.currentPhase = .failed
                        return }
                    print("Answers:"   , csv)
                    self.currentPhase = .conclusion
                    self.collectedUsability = true
                }
                .navigationTitle("Usability")
                .padding()
            }
            .hidden()
    }

        /*
    @ViewBuilder func usabilityForm_view() -> some View {
        // usabilityForm

        NavigationLink(
            "SHOULDN'T SEE (usabilityForm_view)",
            tag: TopPhases.usabilityForm, selection: $currentPhase) {
                WalkInfoForm {
                    result in
                    guard let infoResult = try? result.get() else {
self.currentFailedPhase = currentPhase
         self.currentPhase = .failed; return}
                    print(infoResult.where, infoResult.distance)
                    self.currentPhase = .conclusion
                    self.collectedUsability = true
                }
                .navigationTitle("Usability")
                .padding()
                .reversionToolbar($showRewindAlert)
            }
            .hidden()
        }
         */


    @ViewBuilder func conclusion_view() -> some View {
        NavigationLink(
            "SHOULDN'T SEE (conclusion_view)",
            tag: TopPhases.conclusion, selection: $currentPhase) {
                ConclusionView { _ in
                    self.currentFailingPhase = .conclusion
                    self.currentPhase = .failed
                }
                .navigationTitle("Finished")
            }
            .hidden()
    }

    @ViewBuilder
    func failed_view() -> some View
    {
        // MARK: Failed
        NavigationLink(
            "SHOULDN'T SEE (failed_view)",
            tag: TopPhases.failed, selection: self.$currentFailingPhase) {
                FailureView(failing: TopPhases.walking) { _ in  }
                .navigationTitle("FAILED")
                .padding()
            }
            .hidden()
    }
}
