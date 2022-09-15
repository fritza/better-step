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

    @State var showRewindAlert = false

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





