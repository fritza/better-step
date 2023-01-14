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
                InterstitalPageContainerView(
                    listing: instructionContentList,
                    selection: 1) {_ in
                        self.state = .volume_1
                        UIApplication.shared.isIdleTimerDisabled = true
                    }
                    .padding()
                    .navigationBarBackButtonHidden(true)
            }
            .hidden()
    }
    
    // MARK: - Volume warning
    
    /// Common code for displaying the raise-volume page.
    /// - parameters:
    ///     - current: The stage in the walk order for this display.
    ///     - next:    The stage to follow this one.
    @ViewBuilder
    private func volumeView(_ current: WalkingState,
                    next: WalkingState) -> some View {
        Text("Common volume view unimplemented.")
        #warning("Common volume view unimplemented.")
/*
        NavigationLink(
            "SHOULDN'T SEE (walk_N, \(ownPhase.rawValue))",
            tag: ownPhase, selection: $state)
*/
        
        NavigationLink("SHOULDN'T SEE link for generic volume_nView", tag: current,
                       selection: $state) {
            VolumePageView {
                _ in
                self.state = next
                // First attempt, allow the screen to go
                // dark.
                // UIApplication.shared
                //    .isIdleTimerDisabled = true
            }
            .padding()
            .navigationBarBackButtonHidden(true)
        }
                       .hidden()
    }
    
    /// Display the raise-volume pge the _first_ time.
    @ViewBuilder
    func volume_1View() -> some View {
        volumeView(.volume_1, next: .countdown_1)
    }
    
    /// Display the raise-volume pge the _second_ time.
    @ViewBuilder
    func volume_2View() -> some View {
        volumeView(.volume_2, next: .countdown_2)
    }

    // MARK: - Countdowns
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
                        preconditionFailure("error \(timerError) Can't Happen.")
                        // state = .walk_1

                    }
                }
                // TODO: Compare countdown_2View() modifiers
            }.padding()
            .navigationBarBackButtonHidden(true)
        // ^ these two modifiers were 1 "}" up,
            .hidden()
    }

    // MARK: - Walks 1 and 2
    @ViewBuilder
    /// Common code for conducting the timed (mm:ss) walk.
    /// - Parameters:
    ///   - ownPhase: The walking-container tag this code executes.
    ///   - nextPhaseGood: The tag for the walk phase if the walk proceded to the end.
    ///   - nextPhaseBad: The tag for the walk phase if the walk proceded was cancelled..
    /// - Returns: The `View` that displays the walk timer.
    func walk_N_View(ownPhase: WalkingState, nextPhaseGood: WalkingState, nextPhaseBad: WalkingState) -> some View {
        NavigationLink(
            "SHOULDN'T SEE (walk_N, \(ownPhase.rawValue))",
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
                        Task {
                            let resultData =
                            // Very odd. Isn't there another way to pack up data?
                            await asyncBuffer
                                .allAsTaggedData(
                                    tag: ownPhase.seriesTag!
                                )

                           try! PhaseStorage.shared
                                .series(ownPhase.seriesTag!, completedWith: resultData)
                        }
                        state = nextPhaseGood
                    }
                    // NOTE: state = nextPhaseGood had been here, outside the switch. This is more readable, and I hope still correct.
                }.padding()
                .navigationBarBackButtonHidden(true)
        }
            .hidden()
    }

    
    /// A `NavigationLink` for the first timed walk (`walk_1`, success → `.interstitial_2`, cancellation: → `.interstitial_1` )
    ///
    /// Implemented in terms of `walk_N_View`
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
                    self.state = .volume_2
                }.padding()
                    .navigationBarBackButtonHidden(true)
            }
            .hidden()
    }

    /// A `NavigationLink` for the second, sweep-second, pre-walk countdown (`countdown_2`)
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
    ///
    /// Implemented in terms of `walk_N_View, ` success → `.ending_interstitial`, cancellation: → `.interstitial_1` )
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

                        let passedVal: Result<SuccessValue, Error>
                        switch result {
                        case .success(_)        :
                            passedVal = .success(.sevenDayRecord)
                        case .failure(let error):
                            passedVal = .failure(error)
                        }

                        completion(passedVal)
                    }
            }.padding() // completion closure for end_walkingList
            .navigationBarBackButtonHidden(true)
            .hidden()
    }
}



