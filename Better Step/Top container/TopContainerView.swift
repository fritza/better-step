//
//  TopContainerView.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/14/22.
//

import SwiftUI
import Combine

// onboarding, walking, dasi, usability, conclusion / failed


// MARK: - TopContainerView
/// `NavigationView` that uses invisible `NavigationItem`s for sequencing among phases.
///
///
struct TopContainerView: View {
    @AppStorage(ASKeys.phaseProgress.rawValue) static var latestPhase: String = ""
    @AppStorage(ASKeys.collectedDASI.rawValue) static var collectedDASI: Bool =  false
    @AppStorage(ASKeys.collectedUsability.rawValue) static var collectedUsability: Bool =  false

    @AppStorage(ASKeys.subjectID.rawValue)
    var subjectID: String = SubjectID.unSet

    @AppStorage(ASKeys.collectedDASI.rawValue)
    var collectedDASI: Bool = false
    
    @AppStorage(ASKeys.collectedUsability.rawValue)
    var collectedUsability: Bool = false

    static let defaultPhase = TopPhases.onboarding
    @State var currentPhase: TopPhases? {
        willSet {
            print("Current phase FROM", currentPhase?.description ?? "nil")
        }
        didSet {
            print("Current phase TO", currentPhase?.description ?? "nil")
        }
    }

    init() {

    }

    @State var usabilityFormResults: WalkInfoForm?
    //    @State var showRewindAlert = false

    @State var KILLME_reversionTask: Int? = OnboardContainerView.OnboardTasks
        .firstGreeting.rawValue

    @State var showReversionAlert: Bool = false
    @State var reversionNoticeHandler: NSObjectProtocol!

    // FIXME: mutation won't go well, will it.
    func registerReversionHandler() {
        guard reversionNoticeHandler == nil else {
            print("better not be more than one!")
            return
        }

        let dCenter = NotificationCenter.default
        reversionNoticeHandler =
        dCenter.addObserver(forName: ForceAppReversion,
                            object: nil, queue: .current) {
            notice in
//            currentPhase = Self.defaultPhase

            // FIXME: Surely we'd have to rewind all the subordinate views?
        }
    }

#warning("Make .navigationTitle consistent.")


    // TODO: Do I provide the NavigationView?
    var body: some View {
        NavigationView {
            VStack {
                switch self.currentPhase ?? .onboarding {
                    // MARK: - Onboarding
                case .onboarding:
                    // OnboardContainerView suceeds with String.
                    // That's the entered Subject ID.
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
                        case .success(_):
                            // SuccessValue is
                            // (scores: String, specifics: String)
                            collectedUsability = true
                            if collectedDASI {
                                self.currentPhase = .conclusion
                            }
                            else {
                                self.currentPhase = .dasi
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
                            collectedDASI = true
                            // FIXME: Consider storing the DASI response here.
                            // IS stored (in UserDefaults)
                            // by SurveyContainerView.completionPageView
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
                    // FailureView's completion is NEVER CALLED.
                    // Probably because this is a terminal state
                    // and you can use the gear button to reset.
                }
            }
        }
        .onAppear {
            showReversionAlert = false
            self.currentPhase = Self.defaultPhase
            registerReversionHandler()
        }
        .reversionAlert(on: $showReversionAlert)
    }
}

// MARK: - Preview
struct TopContainerView_Previews: PreviewProvider {
    static var previews: some View {
        TopContainerView()
    }
}





