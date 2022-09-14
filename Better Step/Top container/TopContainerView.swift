//
//  TopContainerView.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/14/22.
//

import SwiftUI

protocol ReportingPhase {
    associatedtype SuccessValue
    var completion: ((Result<SuccessValue, Error>) -> Void)! { get }
    // Each phase must report completion.
    // Meaning it must call the completion closure.
    // The container can expect the reporter's result/failure
}



enum TopPhases: String, CaseIterable, Comparable {
    case onboarding
    case walking
    case conditions
    case usability

    case failed

    static func < (lhs: TopPhases, rhs: TopPhases) -> Bool {
        guard lhs.rawValue != rhs.rawValue else{ return false }
        // By here they arent equal.
        // Across all cases, if lhs is the first-encountered,
        // lhs < rhs. If first match is rhs, lhs > rhs.
        for phase in TopPhases.allCases {
            if      lhs.rawValue == phase.rawValue { return true }
            else if rhs.rawValue == phase.rawValue { return false }
        }
        return false
    }

    static func == (lhs: TopPhases, rhs: TopPhases) -> Bool {
        lhs.rawValue == rhs.rawValue
    }

    func save() {
        let defaults = UserDefaults.standard
        defaults.set(rawValue, forKey: "phaseToken")
    }

    static let `default`: TopPhases = .onboarding
    static func savedPhase() -> TopPhases {
        let defaults = UserDefaults.standard
        if let string = defaults.string(forKey: "phaseToken") {
            return TopPhases(rawValue: string)!
        }
        return Self.default
    }
}

// MARK: - TopContainerView
/// `NavigationView` that uses invisible `NavigationItem`s for sequencing among phases.
struct TopContainerView: View {
    static let defaultPhase = TopPhases.walking
    @State var currentPhase: TopPhases?

    @State private var showRewindAlert = false

    var body: some View {
        NavigationView {
            VStack {
                walking_view()
                failed_view()
                usability_view()
                conditions_view()
                onboarding_view()
            }
            .navigationTitle("Should not see")
            .reversionAlert(next      : $currentPhase,
                            shouldShow: $showRewindAlert)
        }
        .onAppear {
            currentPhase = TopPhases.savedPhase()
        }
        .onDisappear { currentPhase?.save() }
    }
}

// MARK: - Dummies
enum DummyFails: Error {
    case onboardFailure
    case walkingFailure
    case conditionsFailure
    case errorFailure
    case usabilityFailure
}



// MARK: - Preview
struct TopContainerView_Previews: PreviewProvider {
    static var previews: some View {
        TopContainerView(currentPhase: .failed)
    }
}



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


// MARK: Branch views
struct DummyOnboard: View, ReportingPhase {
    var completion: ((Result<Bool, Error>) -> Void)!

    var body: some View {
        VStack {
            Text("Onboard simulator")
            Button("Complete (good)") { completion(.success(true)) }
            Button("Complete (bad)") { completion(.success(false)) }
            Button("Complete (fail)") {
                completion(.failure(DummyFails.onboardFailure))
            }
        }
    }
}


struct DummyWalk: View, ReportingPhase {
    var completion: ((Result<Int, Error>) -> Void)!
    var body: some View {
        VStack {
            Text("Walking simulator")
            Button("Complete (good)") { completion(.success(100)) }
            Button("Complete (bad)") { completion(.success(-10)) }
            Button("Complete (fail)") { completion(.failure(DummyFails.walkingFailure)) }
        }
    }
}

struct DummyConditions: View, ReportingPhase {
    var completion: ((Result<String, Error>) -> Void)!
    var body: some View {
        VStack {
            Text("Conditions simulator")
            Button("Complete (good)") { completion(.success("Went well")) }
            Button("Complete (bad)") { completion(.success("Went badly")) }
            Button("Complete (fail)") { completion(.failure(DummyFails.conditionsFailure)) }
        }
    }
}

struct DummyUsability: View, ReportingPhase {
    var completion: ((Result<String, Error>) -> Void)!
    var body: some View {
        VStack {
            Text("Conditions simulator")
            Button("Complete (good)") { completion(.success("Good")) }
            Button("Complete (bad)") { completion(.success("Bad")) }
            Button("Complete (fail)") { completion(.failure(DummyFails.usabilityFailure)) }
        }
    }
}

struct DummyFailure: View, ReportingPhase {
    var completion: ((Result<String, Error>) -> Void)!
    var body: some View {
        VStack {
            Text("Failure simulator")
            Button("Complete (fail)") { completion(.failure(DummyFails.errorFailure)) }
        }
    }

}

