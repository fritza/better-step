//
//  TimeReader.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/5/22.
//

import Foundation
import Combine

#if LOGGER
import os.log
let logger = Logger()
let signposter = OSSignposter(subsystem: "com.wt9t.G-Bars",
                              category: .pointsOfInterest)
#endif


/// An `ObservableObject` that serves as a single source of truth for the time remaining in an interval, publishing minutes, seconds, and fractions in sync.
final class TimeReader: ObservableObject {

    // FIXME: Need a reset that changes the total interval
    // error("Need a reset that changes the total interval")
    static let shared: TimeReader = TimeReader(
        spanning: CountdownConstants.walkDuration,
        by: CountdownConstants.timerTick)

    enum TerminationErrors: Error, CustomStringConvertible {
        case cancelled
        case expired

        var description: String {
            switch self {
            case .expired  : return "the timer expired"
            case .cancelled: return "the count was cancelled"
            }
        }
    }

    enum TimerStatus: String, Hashable, CustomStringConvertible {
        case ready, running, cancelled, expired
        var description: String { self.rawValue }
    }

    // MARK: Combine support
    var cancellables = Set<AnyCancellable>()

    /// The ready/run/stopped/expired status of the count.
    @Published var status: TimerStatus = .ready

    internal var startingDate, endingDate: Date
    internal var timeSpan: TimeInterval
    internal let tickInterval: TimeInterval
    internal let tickTolerance: TimeInterval



    /*
    /// Broadcasts the current time remaining as rapidly as the underlying `Timer` publishes it.
    /* static */ var timeSubject        = PassthroughSubject<MinSecAndFraction, Never>()
     */
    /// Broadcasts only the number of seconds remaining (pre-walk countdown digit)
    /* static */ var secondsSubject     = PassthroughSubject<Int, Never>()
    /// Broadcats only the fraction  within the current second (sweep-second)
    /* static */ var fractionsSubject   = PassthroughSubject<TimeInterval, Never>()
    /// Broadcasts only minutes and _truncated_ seconds.
    /* static */ var mmssSubject        = PassthroughSubject<MinSecAndFraction, Never>()

#if LOGGER
    var intervalState: OSSignpostIntervalState
#endif





    /// Collect the parameters that will initialize the time publisher and its subscribers when ``start()`` is called.
    /// - Parameters:
    ///   - interval: Duration: the total span of the countdown
    ///   - tickSize: Precision: the interval at which time will be emitted; default `0.01` (100 Hz).
    ///   - function: The call site
    ///   - fileID: The caller's file
    ///   - line: The caller's line number in that file.
    init(spanning total: TimeInterval = CountdownConstants.walkDuration,
         by tickSize: TimeInterval = CountdownConstants.timerTick,
         function: String = #function,
         fileID: String = #file,
         line: Int = #line) {

#if LOGGER
        let spIS = signposter.beginInterval("TimeReader init")
        intervalState = spIS
#endif
        tickInterval = tickSize
        tickTolerance = tickSize / 20.0

        let currentDate = Date()
        timeSpan = total
        startingDate = currentDate
        endingDate = Date().addingTimeInterval(total)
#if LOGGER
        signposter.endInterval("TimeReader init", spIS)
#endif
    }

    /*
     Removed the _publisher() time-tick publisher, redundant and never used.

     I now have four Subjects:
     timeSubject        as in mm:ss.ffff ††
     secondsSubject     as in :<ss>.
     fractionsSubject   as in .<ffff>
     mmssSubject        as in MinSecAndFraction truncated to mm:ss.0000 †

     † Having a zero-fraction output permits suppressing duplicates headed for the Digital view.
        QUERY: how early do we suppress?

     †† Nobody uses the unfiltered mm:ss.ffff direct from the sharedTimePublisher,
        and probably nobody should. It's not useful for sweep (ffff), sweep count (ss), or walk timing (mm:ss)
        Some clients do an .onReceive on timeSubject, but nobody does anything with it.

     SUGGEST:  REMOVE timeSubject.
     CONSIDER: Add a filter before mmssSubject to yield "mm:ss".
        Why:        no other use is made of it.
        Why not:    not a good idea to mingle data (ints) with presentation ("12:34").


     Meanwhile the Subjects are still there.
     But they have significant gaps in function (just
        raw time timeSubect, including ffff
        time (whiole seconds without fractions)
        seconds (Int, no minutes, no fractions)
     The _publisher series echoes that.

     Total needs (reflecting every slice of time the client code wants:
     mm:ss.ffff (not as a Subject, nobody displays the whole thing)
     mm:ss for the walking timer
     ss for the sweep hand to overlay digits
     .fff for the sweep hand

     ANYTHING ELSE?
     I also have a timeSubject, but I wonder if anyone needs the whole thing.

     PLAN
     Abandon the _publisher series.
     Make all publishers private
        Make .sink s  to set the subjects

     There will have to be

     Doc for mmssSubject claims it's top-of-minute.
        Terrible symbol name, and no longer needed: We don't voice large-span units like minutes.
        AND it's unused.

     What about the _Timer functions?
        These emit Publishers to be stored in the Reader; "Not used" means deleting these vars and the _Timer funcs that initialize them.
     HOWEVER, THEY _ARE_ USEFUL FOR THE CHAINS THAT DERIVE THE SUB-UNITS (MMSS, FF, SS) FROM WHICH A .SINK CAN SET THE SUBJECT VALUES.
     THEREFORE HAVE THE _Iimer functions finish the job by ending with .sink s or .assign s.

     BUT SEE: Why had I tried to add a .sink to the ss_Timer() func?

     One reason may be that I wanted to… propagate Errors. The reason this happens though is that I wanted the sinks for the various publishers to hav completion/cancellation notices.
     That can be done by yet another Subject for Error. I think.
     */

    /// Stop the timer and updates `status` to whether it was cancelled or simply ran out.
    func cancel() {
        // ex-fixme: Move `status` into the /* static */ space.
        // ex-warning("`status` should be /* static */.")
        status = (status == .running) ?
            .cancelled : .expired
    }

    #if DEBUG
    deinit {
        print("TimeReader disposed-of")
        print()
    }
    #endif

    func reset(to newTotalSpan: Double) {
        // I hate that
        let currentDate = Date()
        startingDate = currentDate
        endingDate = Date().addingTimeInterval(newTotalSpan)
    }

    /// Initiate the countdown that was set up in `init`.
    ///
    /// Sets up the Combine chains from the `Timer` to all the published interval components.
    func start(totalSpan: Double,
               function: String = #function,
               fileID: String = #file,
               line: Int = #line) {
// FIXME: Callers should somehow take care of restarting MotionManager for walks but not sweeps
        // error("Callers must take care of restarting MotionManager")

/*
 Census of start(~
 () defined on TimeReader
 () defined on MotionManager
 () called on CHHapticEngine in MorseHaptic.init
 (atTime:) on CHHapticPatternPlayer in MorseHaptic.play()
 timer.start() called .onAppear in SweepSecondView [missing total interval] (no conflict(?) Digital's .task starting motion)

 () called on MOTION manager in DigitalTimerView.body.task (No conflict(?) with Sweep's starting timer in .onAppear)
 () on TIMEER in Digital onAppear. s

 () Defined in MinutePublisher  - I don't think .start on MP is done any more
 */



//        print("TimeReader.START called from", function, "\(fileID):\(line)")

        // FIXME: timer status versus expected
        // like ".ready" is getting seriously into misalignment.
        assert(status != .running,
        "attempt to restart a timer")

        reset(to: totalSpan)

        status = .running
    }

    // MARK: - Compulsory out-of-extension
    // FIXME: Make these static
    /* static */ let roundingScale = 100.0
    var sharedTimePublisher: AnyPublisher<MinSecAndFraction, Error>!



}

