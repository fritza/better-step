//
//  TopContainerView.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/14/22.
//

import SwiftUI

protocol ReportingPhase {
    associatedtype SuccessValue
    typealias ResultValue = Result<SuccessValue,Error>
    typealias ClosureType = (ResultValue) -> Void

    var completion: ClosureType { get }

//    var completion: ((Result<SuccessValue, Error>) -> Void)! { get }
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
    case usabilityForm

    case dasi
    /// Interstitial at the end of the user activities
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
    var subjectID: String = SubjectID.unSet
    @AppStorage(AppStorageKeys.collectedDASI.rawValue)
    var collectedDASI: Bool = false
    @AppStorage(AppStorageKeys.collectedUsability.rawValue)
    var collectedUsability: Bool = false

    static let defaultPhase = TopPhases.onboarding
    @State var currentPhase: TopPhases?
    @State var currentFailingPhase: TopPhases?

    @State var usabilityFormResults: WalkInfoForm?

    @State var showRewindAlert = false

    @State var KILLME_reversionTask: Int? = OnboardContainerView.OnboardTasks
        .firstGreeting.rawValue

    init() {
        self.currentPhase = Self.defaultPhase
    }

    var body: some View {
        NavigationView {
            VStack {
                onboarding_view()
                walking_view()

                dasi_view()
                usability_view()

//                usabilityForm_view()

                conclusion_view()
                failed_view()
            }
            .navigationTitle("Should not see")
            .reversionAlert(next      : $KILLME_reversionTask,
                            shouldShow: $showRewindAlert)
        }
        .onAppear {

#if DEBUG
            AppStorageKeys.resetSubjectData()
#endif


            if subjectID == SubjectID.unSet {
                currentPhase = .onboarding
            }
            else { currentPhase = .walking }
        }
//        .onDisappear { currentPhase?.save() }
    }
}

// MARK: - Preview
struct TopContainerView_Previews: PreviewProvider {
    static var previews: some View {
        TopContainerView()
    }
}





