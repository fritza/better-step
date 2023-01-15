//
//  TopContainerView.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/14/22.
//

import SwiftUI
import Combine
import HealthKit

// onboarding, walking, dasi, usability, conclusion / failed


// MARK: - TopContainerView
/// `NavigationView` that uses invisible `NavigationItem`s for sequencing among phases.
///
///
struct TopContainerView: View, MassDiscardable {
    @AppStorage(ASKeys.phaseProgress.rawValue) var latestPhase: String = ""
    
    @State var showReversionAlert: Bool = false
    @State var reversionNoticeHandler: NSObjectProtocol!
    // TODO: Put up an alert when pedometry is not authorized.
    @State var currentPhase: TopPhases
    
    // TODO: Should this be an ObservedObject?
//    @StateObject var phaseStorage = PhaseStorage()
    
    // FIXME: Necessary
    
    var reversionHandler: AnyObject?
    func handleReversion(notice: Notification) {
        ASKeys.revertPhaseDefaults()
        currentPhase = .entry
        TopPhases.resetToFirst()
        // I think it's okay _not_ to clear the reversionHandler
    }
    
    @State var showNoPermission = false
    
    func collect7DayPedometry() {
        PedometryFromHealthKit.securePermission { resultBoolError in
            switch resultBoolError {
            case .failure(let error):
                print("\(#function):\(#line): auth error =", error)
                
            case .success(let okay) where okay:
                let collector = PedometryFromHealthKit(forDays: 7) { dataResult in
                    let data = try! dataResult.get()
                    return try! PhaseStorage.shared.series(
                        .sevenDayRecord,
                        completedWith: data)
                }
                
                collector.proceed()
                
            case .success:
                print("\(#function):\(#line): refused")
                showNoPermission = true
                // TODO: Put up an alert explaining why this is Bad.
            }
        }
    }
    
    init() {
        // TODO: store and reload the current phase ID.
        currentPhase = TopPhases.entry.followingPhase
        self.reversionHandler = self.reversionHandler ?? installDiscardable()
    }
    
    @State private var shouldChallengeHaste_1: Bool = false
    @State private var shouldChallengeHaste_2: Bool = false

    // TODO: Make .navigationTitle consistent
    
    // I provide the NavigationView
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
                            // Absorb OnboardContainerView's (upstream)
                            // SET SubjectID.id (Terminal).
                            SubjectID.id = try result.get()
                            self.currentPhase = self.currentPhase.followingPhase
                            latestPhase = TopPhases.onboarding.rawValue
                        }
                        catch {
                            fatalError("Can't fail out of an onboarding view")
                        }
                    }
                    // .onAppear to set shouldChallengeHaste_1:
                    // See the .onAppear below for the check for whether this
                    // is a second run in a single calendar day.
                    
                    // MARK: - Warn of overwrite
                    .alert("Repeating a Session",
                           isPresented:  $shouldChallengeHaste_1
                    ) {
                        Button("Repeat" , role: .destructive) {
                            shouldChallengeHaste_2 = true
                        }
                        Button("Keep", role: .cancel) {
                        }
                    }
                message: {
                    Text("You’ve performed a session already today. Repeating on the same day will overwrite the earlier session.\n\nAre you sure you want to do that?")
                }   // message/alert


                    // MARK: - Double-check overwrite
                .alert("Making Sure…",
                       isPresented:  $shouldChallengeHaste_2
                ) {
                    Button("Yes, Repeat" , role: .destructive) {
                        shouldChallengeHaste_2 = true
                    }
                    Button("Cancel", role: .cancel) {
                    }
                }
                message: {
                    Text("Are you comfortable with replacing today’s session with another one? This cannot be undone")
                    // FIXME: - This will override the first-completed flag.
                }   // haste_2 message/alert

                    // ===================================================
                    
                    
                    .onDisappear {
                        collect7DayPedometry()
                    }
                    
                case .greeting:
                    ApplicationGreetingView {_ in
                        self.currentPhase = .walking
                    }
                    .onDisappear {
                        collect7DayPedometry()
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
                                                        
                            TopPhases.latestPhase = TopPhases.usability.rawValue
                            self.currentPhase = currentPhase.followingPhase
                            
                            
                            
                            let dasiResponse = try responseResult.get()
                            let csvd = dasiResponse.csvData
                            
                            try! PhaseStorage.shared
                                .series(.dasi, completedWith: csvd)
                        }
                        catch {
                            self.currentPhase = .failed
                            // TODO: Maybe pass the error into the failure view?
                        }
                    }
                    
                    // MARK: - Conclusion (success)
                case .conclusion:
                    // ConclusionView records the last-completed date.
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
                    preconditionFailure("Should not be able to reach phase \(self.currentPhase.description)")
                }   // Switch on currentPhase
            }       // VStack
                    // MARK: - onAppear {}
            .onAppear {
                showReversionAlert = false
                // Alert if this is a fresh run on the same calendar day.
                shouldChallengeHaste_1 = ASKeys.tooEarlyToRepeat
                
                // Report the 7-day summary
                // SeriesTag.sevenDayRecord
                
                
            }       // NavigationView modified
            .reversionAlert(on: $showReversionAlert)
            .environmentObject(WalkInfoResult())
        } // end VStack
        .alert("No Daily Records",
               isPresented: $showNoPermission, actions: { },
               message: {
            Text("Without your permission, [OUR APP] cannot report your seven-day step counts.\n\nTo allow these reports, enable them in\n\nSettings > Privacy & Securoty > Health\nor\nHealth > Browse > Activity > Steps")
        })        
    }
    
}
// MARK: - Preview
struct TopContainerView_Previews: PreviewProvider {
    static var previews: some View {
        TopContainerView()
    }
}
