//
//  WalkingContainer+Phases.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/14/22.
//

import Foundation
import SwiftUI


private let instructionContentList     = try! InterstitialList(baseName: "walk-intro"       )
private let mid_instructionContentList = try! InterstitialList(baseName: "second-walk-intro")
private let end_walkingContentList     = try! InterstitialList(baseName: "usability-intro"  )

// MARK: - Walking stages
extension WalkingContainerView {

    /// A `NavigationLink` for initial instructions (`interstitial_1`)
    @ViewBuilder
    func interstitial_1View() -> some View {
        NavigationLink(
            "SHOULDN'T SEE (interstitial_1)",
            tag: WalkingState.interstitial_1, selection: $state) {
                InterstitalPageContainerView(listing: instructionContentList, selection: 1) {_ in
                    UIApplication.shared.isIdleTimerDisabled = true
                    // See the completion calls for the setting to false
        #if DEBUG
                    print("\(#function): \(#fileID):\(#line)", "Disabled the timer when completed from Interstitial 1")
        #endif

                    self.state = .countdown_1
                }.padding()
                    .navigationBarBackButtonHidden(true)
            }
            .hidden()
    }

    /// A `NavigationLink` for the first pre-walk countdown (`countdown_1`)
    @ViewBuilder
    func countdown_1View() -> some View {
        NavigationLink(
            "SHOULDN'T SEE (countdown_1)",
            tag: WalkingState.countdown_1, selection: $state) {

                // FIXME: Have the ssv report .completed as .success.
                SweepSecondView(duration: CountdownConstants.sweepDuration) {
                    result in
                    guard case let .failure(err) = result,
                          let timerError = err as? Timekeeper.Status else {
                        preconditionFailure("“sucess” Can't Happen. It's a void")
                    }
                    switch timerError {
                    case .completed:
                        state = .walk_1
                    case .cancelled:
                        state = .interstitial_1
                    default:
                        preconditionFailure("error \(timerError) Can't Happen.")// state = .walk_1

                    }
                }
                // TODO: Compare countdown_2View() modifiers
            }.padding()
            .navigationBarBackButtonHidden(true)
        // ^ these two modifiers were 1 "}" up,
            .hidden()
    }

    @ViewBuilder
    func walk_N_View(ownPhase: WalkingState, nextPhaseGood: WalkingState, nextPhaseBad: WalkingState) -> some View {
        NavigationLink(
            "SHOULDN'T SEE (walk_N, \(ownPhase.csvPrefix!))",
            tag: ownPhase, selection: $state)
        {
            DigitalTimerView(
                duration: CountdownConstants
                    .walkDuration,
                walkingState: ownPhase) {
                    result  in
                    UIApplication.shared.isIdleTimerDisabled = false

                    switch result {
                    case .failure(_):   // Should be AppPhaseErrors.walkingPhaseProbablyKilled
                        state = nextPhaseBad

                    case .success(let asyncBuffer):
                        let wcrS = WalkingContainerResult.shared
                        wcrS[ownPhase] = asyncBuffer
                        guard let phasePrefix = ownPhase.csvPrefix,
                              phasePrefix.hasPrefix("walk")
                        else {
                            fatalError("got unknown phase “\(ownPhase.rawValue)”")
                        }
                        wcrS.exportWalksIfReady(
                            tag: phasePrefix,
                            subjectID: SubjectID.id)
                        state = nextPhaseGood
                    }
                    // NOTE: state = nextPhaseGood had been here, outside the switch. This is more readable, and I hope still correct.
                }.padding()
                .navigationBarBackButtonHidden(true)
        }
            .hidden()
    }


    /// A `NavigationLink` for the first timed walk (`walk_1`)
    @ViewBuilder
    func walk_1View() -> some View {
        walk_N_View(ownPhase     : .walk_1,
                    nextPhaseGood: .interstitial_2,
                    nextPhaseBad : .interstitial_1)
    }

    /// A `NavigationLink` for the interstitial view between the two walk sequences (`interstitial_2`)
    @ViewBuilder
    func interstitial_2View() -> some View    {
        NavigationLink(
            "SHOULDN'T SEE (interstitial_2)",
            tag: WalkingState.interstitial_2, selection: $state) {
                InterstitalPageContainerView(listing: mid_instructionContentList, selection: 1) { _ in
                    UIApplication.shared.isIdleTimerDisabled = true
                    // See the completion calls for the setting to false
        #if DEBUG
                    print("\(#function): \(#fileID):\(#line)", "Disabled the timer when completed from Interstitial 2")
        #endif

                    // → .countdown_2
                    self.state = .countdown_2
                }.padding()
                    .navigationBarBackButtonHidden(true)
            }
            .hidden()
    }

    /// A `NavigationLink` for the second pre-walk countdown (`countdown_2`)
    @ViewBuilder
    func countdown_2View() -> some View {
        NavigationLink(
            "SHOULDN'T SEE (countdown_2)",
            tag: WalkingState.countdown_2, selection: $state) {
                SweepSecondView(duration: CountdownConstants.sweepDuration) {
                    result in
                    guard case let .failure(err) = result,
                          let timerError = err as? Timekeeper.Status else {
                        preconditionFailure("“sucess” Can't Happen. It's a void")
                    }
                    switch timerError {
                    case .completed:
                        state = .walk_2
                    case .cancelled:
                        state = .interstitial_1
                    default:
                        preconditionFailure("error \(timerError) Can't Happen.")// state = .walk_1
                    }
                }.padding()
                    .navigationBarBackButtonHidden(true)
            }
            .hidden()
    }

    /// A `NavigationLink` for the second timed walk (`walk_2`)
    func walk_2View() -> some View {
        walk_N_View(ownPhase     : .walk_2,
                    nextPhaseGood: .ending_interstitial,
                    nextPhaseBad : .interstitial_1)
    }

    /// A `NavigationLink` for the closing screen (`ending_interstitial`)
    @ViewBuilder
    func ending_interstitialView() -> some View {
        // REGULAR farewell to the user.
        NavigationLink(
            "SHOULDN'T SEE (ending_interstitial)",
            tag: WalkingState.ending_interstitial, selection: $state) {
                InterstitalPageContainerView(
                    // Not walk-demo, the ending interstitial goodbye is the end. (Loops around.)
                    listing: end_walkingContentList, selection: 1) { result in
                        switch result {
                        case .success(_)        : completion(nil)
                        case .failure(let error): completion(error)
                        }
                        // FIXME: Can't pass an error back through completion.
                        //                        completion(nil)
                        //                        self.state = .interstitial_1
                    }
            }.padding() // completion closure for end_walkingList
            .navigationBarBackButtonHidden(true)
            .hidden()
    }
}



