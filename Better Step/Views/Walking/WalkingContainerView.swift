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


 Better Step:

 Did the walking phase skip the second walk?

 */
#warning("Did this skip the second walk?")

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
    @State var state: WalkingState?
    @State private var shouldShowActivity = false
    @State private var walkingData = Data()

    init(completion: @escaping WCVClosure) {
        self.state = .interstitial_1
        self.completion = completion

#if ALLOW_AVAUDIO
        // The idea is to get AVAudioPlayer to preheat:
        _ = AudioMilestone.shared
#endif

        notificationHandlers = registerDataDeletion()
    }
    //((Result<[CMAccelerometerData], Error>) -> Void)!
    //    ) {
    //        self.completion = completion
    //    }

    var notificationHandlers: NSObjectProtocol?

    func registerDataDeletion() -> NSObjectProtocol {
        let dCenter = NotificationCenter.default

        // TODO: Should I set hasCompletedSurveys if the walk is negated?
        let catcher = dCenter
            .addObserver(
                forName: Destroy.walk.notificationID,
                object: nil,
                queue: .current)
        { _ in
#if ALLOW_AVAUDIO
            // Stop the playback
            AudioMilestone.shared.stop()
#endif

            // Delete what's at the output URL,
            // which should amount to everything,
            // .csv, .zip ...
            CSVArchiver.clearSharedArchiver()
        }
        return catcher
    }

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
//        .environmentObject(MotionManager(phase: .walk_1))
        .onAppear {
//            notificationHandlers =  registerDataDeletion()

            // Prevent sleep
            // See the completion calls for the setting to false



/*


            assert(UIApplication.shared.isIdleTimerDisabled == false,
            "before setting 'disabled', timer-disabled should be false")
            UIApplication.shared.isIdleTimerDisabled = true
#if DEBUG
            print("\(#function): \(#fileID):\(#line)", "Disabled the timer")
#endif

*/



        }
        .onDisappear {
            // Permit sleep
//            UIApplication.shared.isIdleTimerDisabled = false
//            #if DEBUG
//            print(#function, ": \(#fileID):\(#line)", "Enabling the timer")
//            #endif
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
            tag: ownPhase, selection: $state) {
                DigitalTimerView(duration: CountdownConstants.walkDuration,
                                 walkingState: ownPhase) {
                    result  in
                    switch result {

                    case .failure(_):   // Should be AppPhaseErrors.walkingPhaseProbablyKilled
                        state = nextPhaseBad
                        return

                    case .success(let incoming):
                        let wcrS = WalkingContainerResult.shared
                        wcrS[ownPhase] = incoming
                        wcrS.exportWalksIfReady()
                    }

                    state = nextPhaseGood
                }.padding()
                    .navigationBarBackButtonHidden(true)
            }
//            .environmentObject(MotionManager(phase: ownPhase))
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

/*
                        print("\(#function): \(#fileID):\(#line)", "Enabling the timer")
                        assert(UIApplication.shared.isIdleTimerDisabled == true,
                        "Before setting enabled, 'disabled' should be true")

                        UIApplication.shared.isIdleTimerDisabled = false
*/

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

    // MARK: - Preview
    struct WalkingContainerView_Previews: PreviewProvider {

        static var previews: some View {
            WalkingContainerView() {
                _ in
            }
            .environmentObject(MotionManager(phase: .walk_2))
        }
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
