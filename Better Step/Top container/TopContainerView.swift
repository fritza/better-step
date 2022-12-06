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

    init() {
        currentPhase = TopPhases.entry.followingPhase
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
            currentPhase = .entry
            TopPhases.resetToFirst()

            // FIXME: Surely we'd have to rewind all the subordinate views?
        }
    }

    // TODO: Make .navigationTitle consistent


    // TODO: Do I provide the NavigationView?
    var body: some View {
        NavigationView {
#if false
            VStack {
                switch self.currentPhase ?? .entry.followingPhase! {
                    // MARK: - Onboarding
                case .onboarding:
                    // OnboardContainerView suceeds with String.
                    // That's the entered Subject ID.
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

                    // MARK: - Walking
                case .walking:
                    // FIXME: WalkingContainerView is not a RepotingPhase.")
                    WalkingContainerView { error in
                        if let error {
                            print("Walk failed:", error)
                            self.currentPhase = .failed
                        }
                        else {
                            TopPhases.latestPhase = TopPhases.walking.rawValue
                            self.currentPhase = currentPhase?.followingPhase
                            self.performedWalk = true
                        }
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
                    SurveyContainerView { response in
                        do {
                            // FIXME: Consider storing the DASI response here.
                            // IS stored (in UserDefaults)
                            // by SurveyContainerView.completionPageView

                            let dasiResponse = try response.get()
                            collectedDASI = true
                            TopPhases.latestPhase = TopPhases.usability.rawValue
                            self.currentPhase = currentPhase?.followingPhase
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
                    // MARK: - Failure (app-wide)
                case .failed:
                    FailureView(failing: TopPhases.walking) { _ in
                        // FIXME: Dump all data
                    }
                    .reversionToolbar($showRewindAlert)
                    .navigationTitle("FAILED")
                    .padding()
                    // FailureView's completion is NEVER CALLED.
                    // Probably because this is a terminal state
                    // and you can use the gear button to reset.

                default:
                    preconditionFailure("Should not be able to reach phase \(self.currentPhase?.description ?? "N/A")")
                }   // Switch on currentPhase
                    .onAppear {
                        showReversionAlert = false
                        self.currentPhase = .entry.followingPhase
                        registerReversionHandler()
                    }       // NavigationView modified
                    .reversionAlert(on: $showReversionAlert)
            }       // VStack
#else
            VStack {
                OtherTopView() { _ in }
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


struct OtherTopView: View, ReportingPhase {
    @Namespace var lastFormSection
    typealias SuccessValue = WalkInfoResult
    let completion: ClosureType

    @EnvironmentObject var walkingData: WalkInfoResult

    @State var seeingBottomCount: Int = 0
    @State var hasSeenBottom: Bool = false
    @State var shouldDisplayDoneAlert: Bool = false

    init(_ reporting: @escaping ClosureType) {
        completion = reporting
    }



    // FIXME: Still doesn't help.
    //        The proxy goes out of scope in the
    //        .toolbar definition.
    func scrollToBottom(of proxy: ScrollViewProxy) {
        proxy.scrollTo(lastFormSection, anchor: .bottom)
    }



    var body: some View {
        ScrollViewReader { scrollProxy in
            Form {
                Section("How you did") {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("About how far did you walk, in feet?").lineLimit(2)
                                .minimumScaleFactor(0.75)
                            HStack {
                                //                    if walkInfoContent.distance == nil { Text("⚠️") }
                                Spacer()
                                TextField("feet", value: $walkingData.distance, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                                    .frame(width: 80)
                            }
                        }


                        VStack {
                            // FIXME: The app won't let you recover
                            //        if you don't change the answer.
                            Picker("How hard was your body working?", selection: $walkingData.effort) {
                                ForEach(EffortWalked.allCases, id: \.rawValue) { effort in
                                    Text(effort.rawValue.capitalized)
                                        .tag(effort)
                                }
                            }
                        }

                        VStack(alignment: .leading) {
                            Text("Were you concerned about falling during the walks?")
                                .minimumScaleFactor(0.6)
                            Picker("Concerned about falling?",
                                   selection: $walkingData.fearOfFalling) {
                                Text("Yes")
                                    .tag(true)
                                Text("No")
                                    .tag(false)
                            }
                                   .pickerStyle(.segmented)
                        }

                    }
                }



                Section("Where you walked") {
                    VStack(alignment: .leading) {
                        Text("Where did you perform your walks?")
                        Picker("Where did you walk?",
                               selection: $walkingData.where) {
                            Text("At Home")
                                .tag(WhereWalked.atHome)
                            Text("Away from home")
                                .tag(WhereWalked.awayFromHome)
                        }
                               .pickerStyle(.segmented)
                    }

                    VStack(alignment: .leading) {
                        Text("About how long was the area you walked in, in feet?").lineLimit(2)
                            .minimumScaleFactor(0.75)
                        HStack {
                            Spacer()
                            TextField("feet", value: $walkingData.lengthOfCourse, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                                .frame(width: 80)
                            //                                .padding()
                        }
                        //                        }


                        Text("Did you walk back-and-forth, or in a straight line?")
                            .minimumScaleFactor(0.6)
                        Picker("How did you walk?",
                               selection: $walkingData.howWalked) {
                            Text("Back and Forth")
                                .tag(HowWalked.backAndForth)
                            Text("In a Straight Line")
                                .tag(HowWalked.straightLine)
                        }
                               .pickerStyle(.segmented)
                               .onAppear {
                                   seeingBottomCount += 1
                                   hasSeenBottom = seeingBottomCount >= 2
                               }
                    }
                    .tag(lastFormSection)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {

                        if !hasSeenBottom {
                            shouldDisplayDoneAlert = true
                            hasSeenBottom = true


                            // The Done button is tapped.
                            // Has the user scrolled down all the way before?
                            //   (hasSeenBottom)
                            // If not, put the alert up.
                        }
                        else {
                            completion(.success(walkingData))
                        }
                    }
                }
            }
            .background(.thinMaterial)
        }
            .alert("Scroll Down",
                   isPresented: $shouldDisplayDoneAlert,
                   actions: {},
                   message: {
                Text("Please scroll down to review your answers to the items at the end of this list.")
            }
            )
            .navigationTitle("Your Walks")
    }
}

struct OtherTopView_Previews: PreviewProvider {
    static var previews: some View {
        OtherTopView {
            _ in print("POP!")
        }
        .environmentObject(WalkInfoResult())
    }
}


