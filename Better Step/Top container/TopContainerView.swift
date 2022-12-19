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
    @AppStorage(ASKeys.phaseProgress.rawValue) var latestPhase: String = ""
    @AppStorage(ASKeys.collectedDASI.rawValue) var collectedDASI: Bool =  false
    @AppStorage(ASKeys.perfomedWalk.rawValue)  var performedWalk: Bool =  false
    @AppStorage(ASKeys.collectedUsability.rawValue) var collectedUsability: Bool =  false


    // FIXME: Necessary

    @AppStorage(ASKeys.daysSince7DayReport.rawValue) var daysSince7DayReport = 0





    @AppStorage(ASKeys.subjectID.rawValue)
    var subjectID: String = SubjectID.unSet

    @State var currentPhase: TopPhases? {
        willSet {
            print("Current phase FROM", currentPhase?.description ?? "nil")
        }
        didSet {
            print("Current phase TO", currentPhase?.description ?? "nil")
        }
    }

    func dummyPedometry() ->  Pedometry {
        let retval = Pedometry {
            result in
            let string = try! result.get()
            let line = string.csvLine
            let strData = line.data(using: .utf8)!
            // FIXME: Why can't csvData work on [String]?
            PhaseStorage.shared
                .series(.sevenDayRecord, completedWith: strData)
        }
        return retval
    }

    init() {
        currentPhase = TopPhases.entry.followingPhase

        // MARK: - (MOCKED) 7-day pedometry
    }

    @State var showReversionAlert: Bool = false
    @State var reversionNoticeHandler: NSObjectProtocol!
    // TODO: Put up an alert when pedometry is not authorized.

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
            currentPhase = .entry
            TopPhases.resetToFirst()

            // FIXME: Surely we'd have to rewind all the subordinate views?
        }
    }

    // TODO: Make .navigationTitle consistent


    // TODO: Do I provide the NavigationView?
    var body: some View {
        NavigationView {
#if true
            VStack {
                switch self.currentPhase ?? .entry.followingPhase! {
                    // MARK: - Onboarding
                case .onboarding:
                    // OnboardContainerView suceeds with String.
                    // That's theThat's the entered Subject ID.
                    OnboardContainerView {
                        result in
                        do {
                            SubjectID.id = try result.get()
                            self.currentPhase = self.currentPhase?.followingPhase
                            latestPhase = TopPhases.onboarding.rawValue
                        }
                        catch {
                            fatalError("Can't fail out of an onboarding view")
                        }
                    }
                    .onDisappear {
                        dummyPedometry()
                            .proceed()
                    }
                    
                case .greeting:
                    ApplicationGreetingView {_ in 
                        self.currentPhase = .walking
                    }

                    // MARK: - Walking
                case .walking:
                    // NO. the container view is able
                    // to collect more than one completion.
                    WalkingContainerView() {
                        _ in
                        let whatFollows = currentPhase?.followingPhase
                        currentPhase = whatFollows
                    }
                    
                    // MARK: - Usability
                case .usability:
                    UsabilityContainer { result in
                        switch result {
                        case .success(_):
                            // SuccessValue is
                            // (scores: String, specifics: String)
                            currentPhase = currentPhase?.followingPhase
                            collectedUsability = true
                            latestPhase = TopPhases.usability.rawValue
                            // FIXME: Add the usability form
                            //        to the usability container.

                        case .failure:
                            // TODO: Maybe pass the error into the failure view?
                            self.currentPhase = .failed
                        } // switch on callback result
                    }  // UsabilityContainer

                    // MARK: - DASI
                case .dasi:
                    SurveyContainerView {
                        responseResult in
                        do {
                            // FIXME: Consider storing the DASI response here.
                            // IS stored (in UserDefaults)
                            // by SurveyContainerView.completionPageView



                            collectedDASI = true
                            TopPhases.latestPhase = TopPhases.usability.rawValue
                            self.currentPhase = currentPhase?.followingPhase



                            let dasiResponse = try responseResult.get()
                            let csvd = dasiResponse.csvData

                            PhaseStorage.shared
                                .series(.dasi, completedWith: csvd)
                        }
                        catch {
                            self.currentPhase = .failed
                            // TODO: Maybe pass the error into the failure view?
                        }
                    }

                    // MARK: - Conclusion (success)
                case .conclusion:
                    ConclusionView { _ in
                        self.currentPhase = .entry.followingPhase
                        latestPhase = TopPhases.conclusion.rawValue
                    }
                    .navigationTitle("Finished")
                    //                .reversionToolbar($showRewindAlert)
                    //
                    // MARK: - Conclusion (failed)
                case .failed:
                    FailureView(failing: TopPhases.walking) { _ in
                        // FIXME: Dump all data
                    }
                    .navigationTitle("FAILED")
                    .padding()

                    // MARK: - no such phase
                default:
                    preconditionFailure("Should not be able to reach phase \(self.currentPhase?.description ?? "N/A")")
                }   // Switch on currentPhase
            }       // VStack
            .onAppear {
                showReversionAlert = false
                self.currentPhase = .entry.followingPhase
                registerReversionHandler()

                // Report the 7-day summary
                // SeriesTag.sevenDayRecord


            }       // NavigationView modified
            .reversionAlert(on: $showReversionAlert)
#else
            VStack {
                WalkUsabilityForm() { _ in }
                // TODO: The callback should trigger marshalling
                //       of the form data, which will be passed up for
                //       phase results when both are received

            }
            .environmentObject(WalkInfoResult())
#endif
        } // end VStack
    }

}
// MARK: - Preview
struct TopContainerView_Previews: PreviewProvider {
    static var previews: some View {
        TopContainerView()
    }
}
