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
    //    case usabilityForm

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
    @State var currentPhase: TopPhases? {
        didSet {
            print("top currentPhase changes to", currentPhase?.rawValue ?? "NONE")
            print()
        }
    }
    @State var currentFailingPhase: TopPhases?
    @State var usabilityFormResults: WalkInfoForm?
    @State var showRewindAlert = false

    @State var KILLME_reversionTask: Int? = OnboardContainerView.OnboardTasks
        .firstGreeting.rawValue

    init() {
        self.currentPhase = Self.defaultPhase
    }


    // TODO: Do I provide the NavigationView?
    var body: some View {
        NavigationView {
            switch self.currentPhase ?? .onboarding {
                // MARK: - Onboarding
            case .onboarding:
                OnboardContainerView {
                    result in
                    do {
                        SubjectID.id = try result.get()
                        self.currentPhase = .walking
                    }
                    catch {
                        fatalError("Can't fail out of an onboarding view")
                    }
                }

                // MARK: - Walking
            case .walking:
#warning("WalkingContainerView is not a RepotingPhase.")

                WalkingContainerView { error in
                    if let error {
                        print("Walk failed:", error)
                        self.currentPhase = .failed
                    }
                    else if !collectedDASI {
                        self.currentPhase = .dasi
                    }
                    else if !collectedUsability {
                        self.currentPhase = .usability
                    }
                    else {
                        self.currentPhase = .conclusion
                    }
                }


                // MARK: - Usability
            case .usability:
                UsabilityContainer { result in
                    switch result {
                    case .success(_)
                        //                        let scoringVector)
                        :

                        // TODO: Save the usability vector
                        // (or pass the string along to
                        // something that will write a file)
                        if !collectedDASI {
                            self.currentPhase = .dasi
                        }
                        else {
                            self.currentPhase = .conclusion
                        }
                        // FIXME: Add the usability form
                        //        to the usability container.

                    case .failure(let error):
                        // TODO: Maybe pass the error into the failure view?
                        self.currentPhase = .failed
                    }
                }

                // MARK: - DASI
            case .dasi:
                SurveyContainerView { response in
                    do {
                        let responseList = try response.get()
                        if !collectedUsability {
                            self.currentPhase = .usability
                        }
                        else {
                            self.currentPhase = .conclusion
                        }
                    }
                    catch {
                        self.currentPhase = .failed
                        // TODO: Maybe pass the error into the failure view?
                    }
                }

                // MARK: - Conclusion (success)
            case .conclusion:
                ConclusionView { _ in
                    self.currentPhase = .onboarding
                }
                .navigationTitle("Finished")
                //                .reversionToolbar($showRewindAlert)

                // MARK: - Failure (app-wide)
            case .failed:
                FailureView(failing: TopPhases.walking) { _ in
                    // FIXME: Dump all data
                }
                //                .reversionToolbar($showRewindAlert)
                .navigationTitle("FAILED")
                .padding()
            }
        }
        .alert("Starting Over",
               isPresented: ResetStatus.shared.$resetAlertVisible) {

            Button("First Run" , role: .destructive) {
                Destroy.dataForSubject.post()
            }

            Button("Cancel", role: .cancel) {
                //                    shouldShow = false
            }
        }
    message: {
        Text("Do you want to revert to the first run and collect subject ID, surveys, and walks?\nYou cannot undo this.")
    }

    }
}

// MARK: - Preview
struct TopContainerView_Previews: PreviewProvider {
    static var previews: some View {
        TopContainerView()
    }
}





