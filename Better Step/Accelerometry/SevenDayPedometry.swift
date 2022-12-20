//
//  SevenDayPedometry.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/12/22.
//

import Foundation
import CoreMotion

// define "last seven days" as date range from midnight ending yesterday, to midnight seven days before.
//
// The report will need dates, not intervals.
// (CERTAINLY Z to account for DST, but one at a time.)
//
// The .csv file should have one record per day
//      each record has SeriesTag, subject ID,
//      (empty) interval, date, count.
//

/*
 Now, wasn't I able to collect thousands of records from elsewhere in Core Motion?
 */


final class Pedometry: ReportingPhase {
    typealias SuccessValue = [String]
    var completion: ClosureType
    init(_ closure: @escaping ClosureType) {
        completion = closure
    }

    func proceed() {
        let mb = Bundle.main
        guard let sampleURL =
                mb.url(forResource: "SevenDaysMockup", withExtension: "csv")
        else {
            fatalError("Could not find SevenDaysMockup.csv")
        }
#warning("No exercise or name on the records or the file name.")
        let fileContent = try! String(contentsOf: sampleURL)
        let records = fileContent.components(separatedBy: "\n").dropLast()
        // FIXME: Remove empty string at end.
        let tagged = records.map { tagline in
            let expanded =  "\(SeriesTag.sevenDayRecord.rawValue),\(SubjectID.id)," + tagline
            return expanded
        }
        
        
        
        let result: ResultValue = .success(tagged)
        completion(result)
    }

    let calendar = Calendar(identifier: .gregorian)
    func dayRange() -> [String] {
        return (0...6).map {
            days in
            return calendar.date(byAdding: .day, value: -days, to: Date())!
        }
        .map(\.ymd)
    }
}
/*
#else
final class Pedometry: ReportingPhase {
    typealias SuccessValue = CMPedometerData

    /// The shared pedometry service, or `nil` if none is available.
    static let cmPedometer: CMPedometer? =
    {
        // TODO: Put up an alert when pedometry is not authorized.
        guard CMPedometer.isStepCountingAvailable(),
        CMPedometer.authorizationStatus() == .authorized else
        { return nil }
        return CMPedometer()
    }()

    static let calendar = Locale.current.calendar


    // FIXME: Unresolved problem of n-day history
    static let dayCount = 7
    // To-wit: Do we submit this set if the previous isn't stale yet? And do we have since-last, or the whole 7 days again.
    // Also bear in mind that when you ask CM back to "7 days ago" it's subject to a 7-day cutoff (I understand this to be if it's noon today, then the oldest and the current daily records will be truncated by half.


    let completion: ClosureType
    #warning("")

//    {
//        // TODO: Why a computed property?
//
//        let rightNow = Date()
//        let differencs = DateComponents(day: Self.dayCount)
//        let lastMidnight = Self.calendar.startOfDay(for: rightNow)
//
//        guard let sevenDaysBefore = Self.calendar.date(
//            byAdding: .day, value: -7, to: lastMidnight) else {
//            fatalError("Can't calculate ~7 days before last midnight")
//        }
//    }

    init?(_ closure: @escaping ClosureType) {
        guard
            Self.cmPedometer != nil,
            CMPedometer.authorizationStatus() == .authorized
        else { return nil }
        self.completion = closure
    }

    func dateSpan(completion: @escaping PedometerCallback) {
        // Return some kind of begin/end interval by calendar date
        // Return it at an interval.
        guard let pedometer = Self.cmPedometer else {
            fatalError("Attempt to read the pedometer when not available.")
        }

        let rightNow = Date()
        let differencs = DateComponents(day: Self.dayCount)
        let lastMidnight = Self.calendar.startOfDay(for: rightNow)

        guard let sevenDaysBefore = Self.calendar.date(
            byAdding: .day, value: -7, to: lastMidnight) else {
            fatalError("Can't calculate ~7 days before last midnight")
        }

        // SEE BELOW [*1*] for the need to drop partials at one or both ende.

    }

    func proceed() {
        // TODO: Make this async.
        pedometer.queryPedometerData(
            from: sevenDaysBefore,
            to: lastMidnight)
        { pedData, error in
            // It's escaping. You can't really signal failure.
            let retval: ResultValue
            if let error {
                retval = .failure(error)
            }
            else if let pedData {




                retval = .success(pedData)
            }
            else {
                fatalError("\(#function) completion: Neither data nor error")
            }
            completion(retval)
        }
    }

    #warning("Add a phase for the 7-day walk")
}

#endif
 */

/*
 [*1*]
 "Only the past seven days worth of data is stored and available for you to retrieve. Specifying a start date that is more than seven days in the past returns only the available data."
 ASK DAN.
 */
// This iteration sucks everything in. The partials _should_ be evident.
// Exactly 7 days before that midnight may run into partial days,
// because I doubt you can rely on "7 midnights ago" still having any
// data on record.
