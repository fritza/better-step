//
//  WalkingContainerView.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/10/22.
//

import SwiftUI
import UniformTypeIdentifiers
import CoreMotion
import Combine

// FIXME: Handle cancellation.

// MARK: - WalkingState
/// Names tasks _within the walk phase,_ as distinct from ``SeriesTag``, which identifies reportable data series.
public enum WalkingState: String, CaseIterable, CustomStringConvertible
{
    case interstitial_1, /* volume_1, */ countdown_1, walk_1
    case interstitial_2, /* volume_2, */ countdown_2, walk_2
    case ending_interstitial, demo_summary
    
    public var description: String { self.rawValue }

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

struct WalkStates: Hashable, CustomStringConvertible {
    let current, good, bad: WalkingState
    
    init(_ current: WalkingState,
         good: WalkingState,
         bad: WalkingState = .interstitial_1) {
        (self.current, self.good, self.bad) =
        (current, good, bad)
    }
    
    var description: String {
        "WalkState “\(current.rawValue)”: good \(good.rawValue), bad \(bad.rawValue)"
    }
    
    func sameState(as other: WalkStates) -> Bool {
        current == other.current
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
///
///  - note: `WalkingContainerVuew` is embeded in the `NavigationView` within ``TopContainerView``. It _contains_ any of the views in `WalkingContainerView+Phases.swuft`

// MARK: - WalkingContainerView
struct WalkingContainerView: View, ReportingPhase {
    typealias SuccessValue = SeriesTag
    var completion: ClosureType

    @EnvironmentObject var motionManager: MotionManager
    @State var state: WalkingState? {
        didSet {
            print(#function, "changing from",
                  oldValue ?? "n/a", "to",
                  state ?? "n/a")
        }
    }
    @State private var shouldShowActivity = false
    @State private var walkingData = Data()

    init(reporter: @escaping ClosureType) {
        self.state = .interstitial_1
        self.completion = reporter

        // The idea is to get AVAudioPlayer to preheat:
        _ = AudioMilestone.shared
    }

    private var cancellables: [AnyCancellable] = []
    mutating func setUpCombine() {
        revertAllNotification
            .sink { _ in
                AudioMilestone.shared.stop()
            }
            .store(in: &cancellables)
    }
    var notificationHandlers: NSObjectProtocol?

    // MARK: body
    var body: some View {
        // NOTE: This stack is contained in a `NavigationView` within ``TopContainerView``.
        VStack {
            interstitial_1View()
            countdown_1View()
            walk_1View()
            
            interstitial_2View()
            countdown_2View()
            walk_2View()
            
            ending_interstitialView()
            // the volume view OUGHT to come BEFORE the final view in the sequence (the final view refers specifically to proceeding with the walk).
        }   // VStack
    } // body
}

// MARK: - Preview
struct WalkingContainerView_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {

            WalkingContainerView() {
                error in
                print("Error!", error)
            }
        }
        .environmentObject(MotionManager())
    }
}
