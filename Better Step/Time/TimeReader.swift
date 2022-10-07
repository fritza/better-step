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

enum CountdownConstants {
#if DEBUG
    static let walkDuration    = 120.0             // 15.0
#else
    static let walkDuration    = 120.0
#endif

    static let countdownInterval    = 30
    static let sweepDuration        = 5.0
}


/// An `ObservableObject` that serves as a single source of truth for the time remaining in an interval, publishing minutes, seconds, and fractions in sync.
final class TimeReader: ObservableObject {
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
    var mmss_00_publisher: AnyPublisher<MinSecAndFraction, Error>!
    var mmss_ff_publisher: AnyPublisher<MinSecAndFraction, Error>!
    var ss_publisher: AnyPublisher<Int, Error>!

    /// The ready/run/stopped/expired status of the count.
    @Published var status: TimerStatus = .ready

    internal var startingDate, endingDate: Date
    internal var totalInterval: TimeInterval
    internal let tickInterval: TimeInterval
    internal let tickTolerance: TimeInterval

    // MAJOR DEVELOPMENT: sharedTimePublisher IS NOW STATIC
    private static let sharedTimePublisher = createSharedTimePublisher()



    /// Broadcasts the current time remaining as rapidly as the underlying `Timer` publishes it.
    var timeSubject = PassthroughSubject<MinSecAndFraction, Error>()
    /// Broadcasts only the number of seconds remaining
    var secondsSubject = PassthroughSubject<Int, Error>()

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
    init(interval: TimeInterval,
         by tickSize: TimeInterval = 0.01,
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
        totalInterval = interval
        startingDate = currentDate
        endingDate = Date().addingTimeInterval(interval)
#if LOGGER
        signposter.endInterval("TimeReader init", spIS)
#endif
    }


#error("Wrong way to reset the publishers.")

    // FIXME: Are the nil-outs of the publishers necessary?
    //        Can’t we just keep the publishers around and
    //        start/stop/cancel/reset the shared time publisher?
    //        Below and elsewhere, we nuke all the publishers.
    //        I wonder if that's necessary. Maybe you need only singletons of these.
    var sharedTimer                 : AnyPublisher<MinSecAndFraction, Error>!
    var timePublisher       : AnyPublisher<MinSecAndFraction, Error>!
    var mmssPublisher       : AnyPublisher<MinSecAndFraction, Error>!
    var secondsPublisher    : AnyPublisher<Int          , Error>!
    var fractionsPublisher  : AnyPublisher<Double           , Error>!
    #error("What do we do with Errors?")
    // Well, your terminal sink assign, or whatever
    // catches the completion in sink and… that stops the
    // subscriber, doesn't it? Or you can do a cancel
    // (it's AnyCancellable, right?) which would wreck the
    // whole stream (which is what you want).
    // I'm afraid you'd have to re-create the timing chain, though.

    /*
     TWO SETS OF AnyPublishers?!
     TimeReader ~Publisher, as just above (ll 111-116).

     TimeReader ~_publisher, as at ll 50-53.
         ... which, thank God, are declared but not used.
     Does not include a sharedTimer, not a fractions publisher.
     Does include cancellables, not used, which makes sense given that we no longer have any cancellable source.

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
        status = (status == .running) ?
            .cancelled : .expired

        // FIXME: There's a way to stop a Timer.Publisher.
        //        Could you maybe insert a filter that
        //        watches a flag you set, that will
        //        stop publishing until the flag is reset?
        //
        Self.sharedTimePublisher.cancel()

//        timePublisher      = nil
//        mmssPublisher      = nil
//        secondsPublisher   = nil
//        fractionsPublisher = nil

//        sharedTimer = nil
    }

    #if DEBUG
    deinit {
        print("TimeReader disposed-of")
        print()
    }
    #endif

    func reset() {
        // I hate that
        let currentDate = Date()
        startingDate = currentDate
        endingDate = Date().addingTimeInterval(totalInterval)

    }

    /// Initiate the countdown that was set up in `init`.
    ///
    /// Sets up the Combine chains from the `Timer` to all the published interval components.
    func start(function: String = #function,
               fileID: String = #file,
               line: Int = #line) {
//        print("TimeReader.START called from", function, "\(fileID):\(line)")

        // FIXME: timer status versus expected
        // like ".ready" is getting seriously into misalignment.
        assert(status != .running,
        "attempt to restart a timer")

        reset()

        status = .running

        timeCancellable = mmss_ff_Cancellable()
        mmssCancellable = mmss_00_Cancellable()
        secondsCancellable = ss_Cancellable()
    }
    static let roundingScale = 100.0

}

