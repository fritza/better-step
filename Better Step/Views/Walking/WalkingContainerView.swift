//
//  WalkingContainerView.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/10/22.
//

import SwiftUI
import UniformTypeIdentifiers
import CoreMotion

// FIXME: Handle cancellation.

// MARK: - WalkingState
/// Names tasks _within the walk phase,_ as distinct from ``SeriesTag``, which identifies reportable data series.
public enum WalkingState: String, CaseIterable // , BSTAppStages
{
    case interstitial_1, countdown_1, walk_1
    case interstitial_2, countdown_2, walk_2
    case ending_interstitial, demo_summary

    /// The first field in an CSV data report, and the last element of a series data file name.
    public var csvPrefix: String? {
        guard let seriesTag = self.seriesTag else {
            fatalError("\(#function) - tag not known from \(self.rawValue)")
        }
        return seriesTag.rawValue
    }

    /// The reporting phase corresponding to this `WalkingState`.
    ///
    ///  `WalkingState` names a sequence of tasks, two of which lead to reports of data series.
    ///  - returns: The data-series tag corresponding to `.walk_1` and `.walk_2`; otherwise `nil`.
    var seriesTag: SeriesTag? {
        switch self {
        case .walk_1: return SeriesTag.firstWalk
        case .walk_2: return SeriesTag.secondWalk
        default     : return nil
        }
    }
}

/*
 The right but hard way to handle walk-data completion is an observable WalkingContainerResult. EnvObj, singleton, whatever.

 The wrong but easy way is to make them global.
 */
var walkResult_1: Data?
var walkResult_2: Data?


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

        // NEW: appear/disappear prevent/permit sleep.
        .onAppear {
        }
        .onDisappear {
        }
    } // body
}

// MARK: - Preview
struct WalkingContainerView_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {

            WalkingContainerView() {
                error in
                if let error {
                    print("Error!", error)
                }
            }
        }
        .environmentObject(MotionManager())
        //            .environmentObject(MotionManager(phase: .walk_2))
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
