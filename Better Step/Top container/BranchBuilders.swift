//
//  BranchBuilders.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/14/22.
//

import SwiftUI

// MARK: - Branch views
extension TopContainerView {
    // MARK: - Branch links

    @ViewBuilder func onboarding_view() -> some View {
        // MARK: Onboarding
        NavigationLink(
            "SHOULDN'T SEE (onboarding_view)",
            tag: TopPhases.onboarding, selection: $currentPhase) {
                DummyOnboard { result in
                    switch result {
                    case .failure(_):
                        self.currentPhase = .failed

                    case .success(let yes) where yes:
                        self.currentPhase = .walking

                    default:
                        self.currentPhase = .usability
                    }
                }
                .reversionToolbar($showRewindAlert)
                .navigationTitle("Onboarding")
                .padding()
            }
            .hidden()
    }

    @ViewBuilder func walking_view() -> some View {
        // MARK: Walking
        NavigationLink(
            "SHOULDN'T SEE (walking_view)",
            tag: TopPhases.walking, selection: $currentPhase) {
                DummyWalk { result in

                    switch result {
                    case .failure(_):
                        self.currentPhase = .failed
                    case .success(let val) where val >= 0:
                        self.currentPhase = .usability
                    default:
                        self.currentPhase = .conditions
                    }
                }
                Text("walking phase")
                    .navigationTitle("Walking")
                    .padding()
                    .reversionToolbar($showRewindAlert)
            }
            .hidden()
    }

    @ViewBuilder func usability_view() -> some View {
        // MARK: Usability
        NavigationLink(
            "SHOULDN'T SEE (usability_view)",
            tag: TopPhases.usability, selection: $currentPhase) {
                DummyUsability { result in
                    switch result {
                    case .failure(_):
                        self.currentPhase = .failed

                    case .success(let res) where res == "Good":
                        self.currentPhase = .walking

                    case .success:
                        self.currentPhase = .onboarding
                    }
                }
                .navigationTitle("Usability")
                .padding()
                .reversionToolbar($showRewindAlert)
            }
            .hidden()
    }


    @ViewBuilder func conditions_view() -> some View {
        // MARK: Conditions
        NavigationLink(
            "SHOULDN'T SEE (conditions_view)",
            tag: TopPhases.conditions, selection: $currentPhase) {
                DummyConditions { result in
                    switch result {
                    case .failure(_):
                        self.currentPhase = .failed

                    case .success(let val) where val.hasSuffix("well"):
                        self.currentPhase = .usability

                    default:
                        self.currentPhase = .conditions
                    }
                }
                .reversionToolbar($showRewindAlert)
                .navigationTitle("Walking")
                .padding()
            }
            .hidden()
    }

    @ViewBuilder func failed_view() -> some View
    {
        // MARK: Failed
            NavigationLink(
            "SHOULDN'T SEE (failed_view)",
            tag: TopPhases.failed, selection: $currentPhase) {
                DummyFailure { result in
                    switch result {
                    case .failure(_):
                        self.currentPhase = .failed

                    case .success(let val) where val.hasSuffix("well"):
                        self.currentPhase = .usability

                    default:
                        self.currentPhase = .conditions
                    }
                }
                .reversionToolbar($showRewindAlert)
                .navigationTitle("FAILED")
                .padding()
            }
            .hidden()
    }
}
