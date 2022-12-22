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
struct TopContainerView: View, MassDiscardable {
    @AppStorage(ASKeys.phaseProgress.rawValue) var latestPhase: String = ""
    @AppStorage(ASKeys.completedFirstRun.rawValue) var completedFirstRun: Bool = false
//    @AppStorage(ASKeys.collectedDASI.rawValue) var collectedDASI: Bool =  false
//    @AppStorage(ASKeys.perfomedWalk.rawValue)  var performedWalk: Bool =  false
//    @AppStorage(ASKeys.collectedUsability.rawValue) var collectedUsability: Bool =  false


    @State var showReversionAlert: Bool = false
    @State var reversionNoticeHandler: NSObjectProtocol!
    // TODO: Put up an alert when pedometry is not authorized.
    @State var currentPhase: TopPhases

    
    // FIXME: Necessary

    var reversionHandler: AnyObject?
    func handleReversion(notice: Notification) {
        ASKeys.revertPhaseDefaults()
        currentPhase = .entry
        TopPhases.resetToFirst()
        // I think it's okay _not_ to clear the reversionHandler
    }


    func dummyPedometry() ->  Pedometry {
        let retval = Pedometry {
            result in
            let string = try! result.get()
            let line = string.csvLine
            let strData = line.data(using: .utf8)!
            // FIXME: Why couldn't csvData work on [String]?
            PhaseStorage.shared
                .series(.sevenDayRecord, completedWith: strData)
            ASKeys.dateOfLast7DReport = Date()
        }
        return retval
    }

    init() {
        // TODO: store and reload the current phase ID.
        currentPhase = TopPhases.entry.followingPhase
        self.reversionHandler = self.reversionHandler ?? installDiscardable()
        // MARK: - (MOCKED) 7-day pedometry
    }


    // TODO: Make .navigationTitle consistent


    // TODO: Do I provide the NavigationView?
    var body: some View {
        NavigationView {
            VStack {
                switch self.currentPhase {
                    // MARK: - Onboarding
                case .onboarding:
                    // OnboardContainerView suceeds with String.
                    // That's theThat's the entered Subject ID.
                    OnboardContainerView {
                        result in
                        do {
                            SubjectID.id = try result.get()
                            self.currentPhase = self.currentPhase.followingPhase
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
                    .onDisappear {
                        #warning("Just dump it into an async Task")
                        
                        dummyPedometry()
                            .proceed()
                    }

                    // MARK: - Walking
                case .walking:
                    // NO. the container view is able
                    // to collect more than one completion.
                    WalkingContainerView() {
                        _ in
                        let whatFollows = currentPhase.followingPhase
                        currentPhase = whatFollows
                    }
                    
                    // MARK: - Usability
                case .usability:
                    UsabilityContainer { result in
                        switch result {
                        case .success(_):
                            // SuccessValue is
                            // (scores: String, specifics: String)
                            currentPhase = currentPhase.followingPhase
//                            collectedUsability = true
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



//                            collectedDASI = true
                            TopPhases.latestPhase = TopPhases.usability.rawValue
                            self.currentPhase = currentPhase.followingPhase



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
                    preconditionFailure("Should not be able to reach phase \(self.currentPhase.description ?? "N/A")")
                }   // Switch on currentPhase
            }       // VStack
            // MARK: - onAppear {}
            .onAppear {
                showReversionAlert = false
//                self.currentPhase = .entry.followingPhase

                // Report the 7-day summary
                // SeriesTag.sevenDayRecord


            }       // NavigationView modified
            .reversionAlert(on: $showReversionAlert)
            .environmentObject(WalkInfoResult())
        } // end VStack
    }

}
// MARK: - Preview
struct TopContainerView_Previews: PreviewProvider {
    static var previews: some View {
        TopContainerView()
    }
}
