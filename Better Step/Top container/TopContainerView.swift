//
//  TopContainerView.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/14/22.
//

import SwiftUI
import Combine
import HealthKit

// MARK: - TopContainerView
/// `NavigationView` that uses invisible `NavigationItem`s for sequencing among phases.
///
///
struct TopContainerView: View
{
    @State var currentPhase: TopPhases {
        didSet {
            print("current phase from", oldValue, "---", currentPhase)
        }
    }
    @AppStorage(ASKeys.phaseProgress.rawValue) var latestPhase: String = ""
    
    // TODO: Should this be an ObservedObject?
//    @State var showNoPermission = false
    
    private var cancellables: Set<AnyCancellable> = []
    
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
//                showNoPermission = true
                // TODO: Put up an alert explaining why this is Bad.
            }
        }
    }
    
    init() {
        if !SubjectID.isSet {
            // We got here without a Subject ID.
            // Bring everything else to no-data condition.
            NotificationCenter.default
                .post(name: TotalResetNotification, object: nil)
        }
        
        // TODO: store and reload the current phase ID.
        currentPhase = TopPhases.entry.followingPhase
        setUpCompletionNotifications()
    }
    
//    @State private var shouldChallengeHaste_1: Bool = false
//    @State private var shouldChallengeHaste_2: Bool = false

    // TODO: Make .navigationTitle consistent
    
    // I provide the NavigationView
    var body: some View {
        NavigationView {
            VStack {
                switch self.currentPhase {
                    
                    // MARK: - Onboarding
                case .onboarding:
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

                    .onDisappear {
                        collect7DayPedometry()
                    }
                    
                    // NOTE: This element is contained in a `NavigationView` within ``TopContainerView``.
                case .greeting:
                    ApplicationGreetingView {_ in
                        self.currentPhase = .walking
                    }
                    .onDisappear {
                        collect7DayPedometry()
                    }
                    
                    // MARK: - Walking
                case .walking:
                    // NOTE: This element is contained in a `NavigationView` within ``TopContainerView``.
                    WalkingContainerView() {
                        _ in
                        currentPhase = currentPhase.followingPhase
                    }
                    
                    // MARK: - Usability
                case .usability:
                    // NOTE: This element is contained in a `NavigationView` within ``TopContainerView``.
                    UsabilityContainer {
                        _ in
                        currentPhase = currentPhase.followingPhase
                        latestPhase = TopPhases.usability.rawValue
                    }

                    // MARK: - DASI
                case .dasi:
                    SurveyContainerView {
                        responseResult in
                        TopPhases.latestPhase = TopPhases.usability.rawValue
                        self.currentPhase = currentPhase.followingPhase
                        let dasiResponse = try! responseResult.get()
                        let csvd = dasiResponse.csvData

                        try! PhaseStorage.shared
                            .series(.dasi, completedWith: csvd)
                    }
                    
                    // MARK: - Conclusion (success)
                case .conclusion:
                    // ConclusionView records the last-completed date.
                    let pss = PhaseStorage.shared
                    ConclusionView(jsonBaseName: "conclusion") { result in
                        do {
                            guard let handoff = try? result.get(),
                                  handoff == .both else {
                                assertionFailure(
                                    "\(#fileID):\(#line) - didn't expect a ConclusionView "
                                )
                                return
                            }
                            // TODO: In future, handoff may also be sending or finish
                            //      but still not .neither

                            print("Note:", #function, "- \(#fileID):\(#line) - archive write-and-send has been mover here from PhaseStorage.")

                            pss.assertAllComplete()
                            try pss.createArchive()
                            guard let performer = PerformUpload(
                                from: pss.zipOutputURL,
                                named: pss.zipFileName) else {

                                fatalError("\(#fileID):\(#line): PerformUpload not created (\(pss.zipOutputURL.path), ](pss.zipFileName)).")
                            }
                            // Perform the upload.
                            performer.doIt()
                        }
                        catch {
                            fatalError("\(#fileID):\(#line): ZIPArchive not created (\(pss.zipOutputURL.path), ](pss.zipFileName)).")
                        }

                        // Just to make sure:
                        ASKeys.isFirstRunComplete = true
                        self.currentPhase = .entry.followingPhase
                        latestPhase = TopPhases.conclusion.rawValue

                    }                    
                    
                    // MARK: - no such phase
                default:
                    // This includes .entry.
                    // See DocC for ``EmptyPhase``. It's not meant to be visible, it's just a way to set the current phase to .entry.followingPhase 
                    EmptyPhase { _ in
                        self.currentPhase = .entry.followingPhase
                    }
                }   // Switch on currentPhase
            }       // VStack
                    // MARK: - onAppear {}
            .onAppear {
            }       // NavigationView modified
            .environmentObject(WalkInfoResult())
        } // end VStack
    }
    
}

extension TopContainerView {
    fileprivate var completionNoticesSet: Bool {
        !cancellables.isEmpty
    }
    
    private mutating func setUpCompletionNotifications() {
        // TODO: Migrate this into UploadCompletionNotification.swift
        // Prepare to receive upload-complete notifications
        
        // NOTE: If you put up new notifications, be sure to amend `.completionNoticesSet`.
        guard !completionNoticesSet else { return }
        
        NotificationCenter.default.publisher(for: UploadNotification)
            .map { notice -> (Data, HTTPURLResponse) in
                guard let data = notice.object as? Data,
                      let userInfo = notice.userInfo,
                      let response = userInfo["response"] as? HTTPURLResponse
                else {
                    fatalError("error: \(#fileID):\(#line): could not extract upload-completion ")
                }
                return (data, response)
            }
            .sink { (data, response) in
                print("success: \(#fileID):\(#line):")
                print("  --", response.cliffNotes() ?? "n/a")
                
                assert(ASKeys.idAndFirstRunAreConsistent())
            }
            .store(in: &cancellables)
        
        // Removed an observer of UploadErrorNotification.
        // There should be some way to alert the user
        // to errors, but that's not ready yet.
    }
}


// MARK: - Preview
struct TopContainerView_Previews: PreviewProvider {
    static var previews: some View {
        TopContainerView()
    }
}
