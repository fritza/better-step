//
//  BranchBuilders.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/14/22.
//

import SwiftUI

// MARK: - Branch views
/*
extension TopContainerView {

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
                Text("onboarding phase")
                    .navigationTitle("Onboarding")
                    .padding()
                    .navigationBarBackButtonHidden(true)
                    .hidden()
            }
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
                    .navigationBarBackButtonHidden(true)
            }
            .hidden()
    }
    /*
     √ case onboarding
     √ case walking
     √ case conditions
     √ case usability

     case failed
     */

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
                Text("usability phase")
                    .navigationTitle("Usability")
                    .padding()
                    .navigationBarBackButtonHidden(true)
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
                Text("conditions phase")
                    .navigationTitle("Walking")
                    .padding()
                    .navigationBarBackButtonHidden(true)
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
                Text("failure phase")
                    .navigationTitle("FAILED")
                    .padding()
                    .navigationBarBackButtonHidden(true)
            }
            .hidden()
    }
}
*/
