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

// onboarding, walking, dasi, usability, conclusion / failed

enum TopPhases: String, CaseIterable, Comparable {
    case onboarding
    //  `ApplicationOnboardView`.
    //  There are two distinct onboarding tasks:
    //  * New user, greet and collect ID
    //  * detailed explanation (probably different when new)
    case walking
    //  WalkingContainerView
    case usability
    //  UsabilityController
    //      + EnvironmentObject UsabilityController

    case dasi

    //  case conditions
    //  -- had been here, but usability takse care of it.

    case conclusion

    case failed

    //  NOT surveyWrapperView.

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

//    func save() {
//        let defaults = UserDefaults.standard
//        defaults.set(rawValue, forKey: "phaseToken")
//    }

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
    @AppStorage(AppStorageKeys.subjectID.rawValue)
    var subjectID: String = ""
    @AppStorage(AppStorageKeys.collectedDASI.rawValue)
    var collectedDASI: Bool = false
    @AppStorage(AppStorageKeys.collectedUsability.rawValue)
    var collectedUsability: Bool = false


    static let defaultPhase = TopPhases.walking
    @State var currentPhase: TopPhases?

    @State var showRewindAlert = false

    var body: some View {
        NavigationView {
            VStack {
                onboarding_view()
                walking_view()

                dasi_view()
                usability_view()

                conclusion_view()
                failed_view()
            }
            .navigationTitle("Should not see")
            .reversionAlert(next      : $currentPhase,
                            shouldShow: $showRewindAlert)
        }
        .onAppear {
            if subjectID == "" {
                currentPhase = .onboarding
            }
            else { currentPhase = .walking }
        }
//        .onDisappear { currentPhase?.save() }
    }
}

// MARK: - Dummies
enum DummyFails: Error {
    case onboardFailure
    case walkingFailure
    case dasiFailure
    case usabilityFailure
    case conclusionFailure
    case failingFailure
}


// MARK: - Preview
struct TopContainerView_Previews: PreviewProvider {
    static var previews: some View {
        TopContainerView(currentPhase: .failed)
    }
}





