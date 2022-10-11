//
//  WalkingContainerView.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/10/22.
//

import SwiftUI
import UniformTypeIdentifiers
import CoreMotion

/* TODO: Handle cancellation.
 */

protocol HasVoidCompletion {
    var completion: ()->Void { get }
}

// MARK: - WalkingState
public enum WalkingState: String, CaseIterable // , BSTAppStages
{
    case interstitial_1, countdown_1, walk_1
    case interstitial_2, countdown_2, walk_2
    case ending_interstitial, demo_summary

    public var csvPrefix: String? {
        switch self {
        case .walk_1: return "w_1"
        case .walk_2: return "w_2"

        default: return nil
        }
    }
}

/*
 The right but hard way to handle walk-data completion is an observable WalkingContainerResult. EnvObj, singleton, whatever.

 The wrong but easy way is to make them global.
 */
var walkResult_1: Data?
var walkResult_2: Data?


private let instructionContentList     = try! InterstitialList(baseName: "walk-intro"       )
private let mid_instructionContentList = try! InterstitialList(baseName: "second-walk-intro")
private let end_walkingContentList     = try! InterstitialList(baseName: "usability-intro"  )

let csvUTT       = UTType.commaSeparatedText
let csvUTTString = "public.comma-separated-values-text"

/*
 /// Adopters promise to present a `completion` closure for the `WalkingContainerView` to designate the next page.
 protocol StageCompleting {
 /// Informs the creator whether a contained `NavigationLink` destination has completed successfully or not.
 var completion: (Bool) -> Void { get }
 }
 */
/// ## Topics
///
/// ### Introduction
///
/// - ``interstitial_1View()``
///
/// ### First Walk
///
/// - ``countdown_1View()``
/// - ``walk_1View()``
///
/// ### Second Walk
///
/// - ``interstitial_2View()``
/// - ``countdown_2View()``
/// - ``walk_2View()``
///
/// ### Conclusion
///
/// - ``ending_interstitialView()``
/// - ``demo_summaryView()``

/// A wrapper view that programmatically displays stages of the walk test.
///
/// The struct has to know whether the stage is `.interstitial_1` or `.interstitial_2`, because the output file names must be distinct.
///
/// **Theory**
///
/// The view is a succession of `NavigationLink`s, presented one at a time, whose destinations are the various interstitial, countdown, and data collection `View`s :
/// * ``InterstitalPageContainerView``
/// * ``DigitalTimerView``
/// *  ``SweepSecondView``
///
///  Each has a `WalkingState` tag. When that view exits (as by a **Continue** button), the container gets a callback in which it designates the tag for the next view to be displayed.
///
///  As implemented, each NavigationLink is created by its own `@ViewBuilder` so the `body` property need only list them by name.
///  - note: `demo_summaryView()` is presented only if the `INCLUDE_WALK_TERMINAL` compilation flag is set.


struct WalkingContainerView: View {
    typealias WCVClosure = ((Error?) -> Void)
    var completion: WCVClosure

    /*
     ((Result<SuccessValue, Error>) -> Void)!
     */
    @EnvironmentObject var motionManager: MotionManager
    @State var state: WalkingState? = .interstitial_1
    @State private var shouldShowActivity = false
    @State private var walkingData = Data()

    init(completion: @escaping WCVClosure) {
        self.completion = completion
        // The idea is to get AVAudioPlayer to preheat:
        _ = AudioMilestone.shared
    }
    //((Result<[CMAccelerometerData], Error>) -> Void)!
    //    ) {
    //        self.completion = completion
    //    }


    var body: some View {
        //        NavigationView {
        VStack {
            interstitial_1View()
            countdown_1View()
            walk_1View()
            interstitial_2View()
            countdown_2View()
            walk_2View()
            ending_interstitialView()
#if INCLUDE_WALK_TERMINAL
            demo_summaryView()
#endif
        }   // VStack
            //        }       // NavigationView
        .onAppear {
        }
    } // body
}

// MARK: - Walking stages
extension WalkingContainerView {

    /// A `NavigationLink` for initial instructions (`interstitial_1`)
    @ViewBuilder
    func interstitial_1View() -> some View {
        NavigationLink(
            "SHOULDN'T SEE (interstitial_1)",
            tag: WalkingState.interstitial_1, selection: $state) {
                InterstitalPageContainerView(listing: instructionContentList, selection: 1) {_ in
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
                SweepSecondView(duration: CountdownConstants.sweepDuration) {
                    state = .walk_1
                }.padding()
                    .navigationBarBackButtonHidden(true)
            }
            .hidden()
    }

    @ViewBuilder
    func walk_N_View(ownPhase: WalkingState, nextPhase: WalkingState) -> some View {
        NavigationLink(
            "SHOULDN'T SEE (walk_N, \(ownPhase.csvPrefix!))",
            tag: ownPhase, selection: $state) {
                DigitalTimerView(duration: CountdownConstants.walkDuration,
                                 walkingState: ownPhase) {
                    result  in
                    switch result {
                    case .failure(_):   // Should be AppPhaseErrors.walkingPhaseProbablyKilled
                        break
                    case .success(let incoming):
                        let wcrS = WalkingContainerResult.shared
                        wcrS[ownPhase] = incoming

                        if wcrS.readyForExport {
                            let (slowResult, fastResult) = (wcrS.walk_1!, wcrS.walk_2!)
                            //                            for each, write the files, then build an archive.
                            Task {
                                try? await slowResult.addToArchive()
                                try? await fastResult.addToArchive()
                                // FIXME: do something about export failures.
                            }
                        }
                    }

                    // → nextPhase
                    state = nextPhase
                }.padding()
                    .navigationBarBackButtonHidden(true)
            }
            .hidden()
    }


    /// A `NavigationLink` for the first timed walk (`walk_1`)
    @ViewBuilder
    func walk_1View() -> some View {
        walk_N_View(ownPhase: .walk_1,
                    nextPhase: .interstitial_2)
    }

    /// A `NavigationLink` for the interstitial view between the two walk sequences (`interstitial_2`)
    @ViewBuilder
    func interstitial_2View() -> some View    {
        NavigationLink(
            "SHOULDN'T SEE (interstitial_2)",
            tag: WalkingState.interstitial_2, selection: $state) {
                InterstitalPageContainerView(listing: mid_instructionContentList, selection: 1) { _ in
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
                    // → .walk_2
                    state = .walk_2
                }.padding()
                    .navigationBarBackButtonHidden(true)
            }
            .hidden()
    }

    /// A `NavigationLink` for the second timed walk (`walk_2`)
    func walk_2View() -> some View {
        walk_N_View(ownPhase: .walk_2,
                    nextPhase: .ending_interstitial)
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

// MARK: - Preview
struct WalkingContainerView_Previews: PreviewProvider {

    static var previews: some View {
        WalkingContainerView() {
_ in
        }
        .environmentObject(MotionManager(phase: .walk_2))
    }
}

/*      SHOW-ACTIVITY button
 Button {
 shouldShowActivity = true
 }
 label: { Label(
 "Tap to Export",
 systemImage: "square.and.arrow.up")
 }
 .buttonStyle(.bordered)
 */


/*

 }   // NavigationView
 .sheet(isPresented: $shouldShowActivity, content: {
 ActivityUIController(
 //                    data: walkingData,
 data: "01234 N/A 56789".data(using: .utf8)!,
 text: "01234 N/A 56789"
 //textEquivalent)
 )
 }) // .sheet content

 */
