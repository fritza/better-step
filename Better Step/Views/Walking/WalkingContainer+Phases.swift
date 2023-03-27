//
//  WalkingContainer+Phases.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/14/22.
//

import Foundation
import SwiftUI

private let walkingInstructionInfo     = try! CardContent.contentArray(from: ["walk-intro"         ])
private let mid_instructionCardInfo = try! CardContent.contentArray(from: ["second-walk-intro"  ])
private let end_walkingCardInfo     = try! CardContent.contentArray(from: ["walks-complete"     ])



// MARK: - Walking stages
extension WalkingContainerView {

    /// A `NavigationLink` for initial instructions (`interstitial_1`)
    @ViewBuilder
    func interstitial_1View() -> some View {
        // Ignore NavigationLink initialzer deprecation.
        NavigationLink(
            "SHOULDN'T SEE (interstitial_1)",
            tag: WalkingState.interstitial_1,
            selection: $state) {
                
                InterCarousel(content: walkingInstructionInfo) {
                    self.state = .countdown_1
                    UIApplication.shared.isIdleTimerDisabled = true
                }
                .padding()
                .navigationBarBackButtonHidden(true)
            }
            .hidden()
    }

    // MARK: - Countdowns
    /// A `NavigationLink` for the first pre-walk countdown (`countdown_1`)
    @ViewBuilder
    func countdown_1View() -> some View {
        // Ignore NavigationLink initialzer deprecation.
        NavigationLink(
            "SHOULDN'T SEE (countdown_1)",
            tag: WalkingState.countdown_1, selection: $state)
        {
            SweepSecondView(duration: CountdownConstants.sweepDuration
            ) { result in
                collectFromCountdown(
                    result: result,
                    context: .init(
                        .countdown_1,
                        good: .walk_1)
                )
            }
            .padding()
            .navigationBarBackButtonHidden(true)
        }
            .hidden()
    }
    // ^ these two modifiers were 1 "}" up,

    // MARK: - Walks 1 and 2
    @ViewBuilder
    /// Common code for conducting the timed (mm:ss) walk.
    /// - Parameters:
    ///   - ownPhase: The walking-container tag this code executes.
    ///   - nextPhaseGood: The tag for the walk phase if the walk proceded to the end.
    ///   - nextPhaseBad: The tag for the walk phase if the walk proceded was cancelled..
    /// - Returns: The `View` that displays the walk timer.
    func walk_N_View( _ states: WalkStates) -> some View {
        // Ignore NavigationLink initialzer deprecation.
        NavigationLink(
            "SHOULDN'T SEE (walk_N, \(states.current.rawValue))",
            tag: states.current, selection: $state)
        {
#if OMIT_WALKING
            Group {
                Text("Replacing the Digital view (\(states.current.rawValue))")
                Button("Continue") { state = states.good }
            }
            .padding()
            .navigationBarBackButtonHidden(true)
#else
            DigitalTimerView(
                duration: CountdownConstants.walkDuration,
                walkingState: states.current) {
                    result  in collectFromWalk(
                        result: result, ownPhase: states.current,
                        nextPhaseGood: states.good,
                        nextPhaseBad: states.bad)
                }
                .padding()
                .navigationBarBackButtonHidden(true)
#endif
        }
        .hidden()
    }

    
    /// A `NavigationLink` for the first timed walk (`walk_1`, success → `.interstitial_2`, cancellation: → `.interstitial_1` )
    ///
    /// Implemented in terms of `walk_N_View`
    func walk_1View() -> some View {
       return walk_N_View(.init(.walk_1,
                                good: .interstitial_2))
    }

    /// A `NavigationLink` for the interstitial view between the two walk sequences (`interstitial_2`)
    @ViewBuilder
    func interstitial_2View() -> some View    {
        // Ignore NavigationLink initialzer deprecation.
        NavigationLink(
            "SHOULDN'T SEE (interstitial_2)",
            tag: WalkingState.interstitial_2,
            selection: $state) {
                InterCarousel(content: mid_instructionCardInfo) {
                    UIApplication.shared.isIdleTimerDisabled = true
                    self.state = .countdown_2

                }
                .padding()
                .navigationBarBackButtonHidden(true)
            }
            .hidden()
    }

    /// A `NavigationLink` for the second, sweep-second, pre-walk countdown (`countdown_2`)
    @ViewBuilder
    func countdown_2View() -> some View {
        // Ignore NavigationLink initialzer deprecation.
        NavigationLink(
            "SHOULDN'T SEE (countdown_2)",
            tag: WalkingState.countdown_2,
            selection: $state)
        {
            SweepSecondView(
                duration:
                    CountdownConstants.sweepDuration
            )
            { result in
                collectFromCountdown(
                    result: result,
                    context: .init(
                        .countdown_1,
                        good: .walk_2,
                        bad : .interstitial_2)
                )
            }
            .padding()
            .navigationBarBackButtonHidden(true)
        }
            .hidden()
    }
    
    /// A `NavigationLink` for the second timed walk (`walk_2`)
    ///
    /// Implemented in terms of `walk_N_View, ` success → `.ending_interstitial`, cancellation: → `.interstitial_1` )
    func walk_2View() -> some View {
        return walk_N_View(
            .init(.walk_2, good: .ending_interstitial)
        )
    }
    
    /// A `NavigationLink` for the closing screen (`ending_interstitial`)
    @ViewBuilder
    func ending_interstitialView() -> some View {
        // REGULAR farewell to the user.
        // Ignore NavigationLink initialzer deprecation.
        NavigationLink(
            "SHOULDN'T SEE (ending_interstitial)",
            tag: WalkingState.ending_interstitial, selection: $state) {
                InterCarousel(content: end_walkingCardInfo) {
                    // Fixed:: - change success to walking phase
                    completion(.success(.secondWalk))
                }
            }   // completion closure for end_walkingList
            .padding()
            .navigationBarBackButtonHidden(true)
            .hidden()
    }
}

// MARK: - Countdowns
extension WalkingContainerView {
    
    func collectFromCountdown(result: SweepSecondView.ResultValue,
                            context: WalkStates)
    {
        guard case let .failure(err) = result,
              let timerError = err as? Timekeeper.Status else {
            preconditionFailure("\(#fileID):\(#line):  “sucess” Can't Happen. It's a void")
        }
        
        switch timerError {
        case .completed: state = context.good
        case .cancelled: state = context.bad
        default:
            preconditionFailure("error \(timerError) Can't Happen.")
        }
    }
    
    func collectFromWalk(result: DigitalTimerView.ResultValue,
                              ownPhase: WalkingState,
                              nextPhaseGood: WalkingState,
                              nextPhaseBad: WalkingState) {
        // ATW, DigitalTimerView.ResultValue is IncomingAccelerometry
        UIApplication.shared.isIdleTimerDisabled = false
        
        switch result {
        case .failure(_):
            // AppPhaseErrors.walkingPhaseProbablyKilled?
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
    }
}
