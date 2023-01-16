//
//  SevenDayPedometry.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/12/22.
//

import Foundation
import HealthKit
import Algorithms

// MARK: - StepsOnDate
/// Aggregation of a `Date` and a step count.
///
/// `StepsOnDate` sorts ascending by date.
struct StepsOnDate: CSVRepresentable, Comparable
{
    // MARK: Properties
    let steps: Int
    let date : Date

    // MARK: CSVRepresentable
    var csvLine: String {
        // TODO: Why doesn't the [CSVRepresentable] -> csvLine work here?
        assert(SubjectID.id != SubjectID.unSet)
        // SeriesTag.sevenDayRecord
        let components: [String] = [
            SeriesTag.sevenDayRecord.rawValue,
            SubjectID.id,
            date.ymd,
            String(steps)
            ]
        return components.joined(separator: ",")
    }
    
    // MARK: Comparable
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.date < rhs.date
    }
}

// MARK: - PedometryFromHealthKit
/// Collects the previous _n_ (atw 7) days' step counts, reduces them to `Data`, and returns that through a completion closure.
///
/// The list of step counts are for the sum of a day, midnight-to-midnight, ending with the midnight that commences the current day.
final class PedometryFromHealthKit: ReportingPhase {
    // MARK: ReportingPhase
    typealias SuccessValue = Data
    let completion: ClosureType
    
    // MARK: Statics
    static let gregorian = Calendar(identifier: .gregorian)
    static let store = HKHealthStore()
    static let hkStepsType = HKSampleType.quantityType(forIdentifier: .stepCount)!
    
    static func securePermission(completed: @escaping (Result<Bool, Error>) -> Void) {
        let perms = Set([
            HKObjectType.quantityType(forIdentifier: .stepCount)!
        ])
        store
            .requestAuthorization(
                toShare: nil,
                read: perms) { approved, error in
                if let error {
#if DEBUG
print("\(#function):\(#line): auth error =", error)
                    #endif
                    completed(Result.failure(error))
                    return
                }
                
                if approved {
//                    print("\(#function):\(#line):", approved ? "approved" : "refused")
                    completed(Result.success(approved))
                    return
                }
            }
        // FIXME: getRequestStatusForAuthrization
    }
    
    // MARK: Properties
    /// The expected number of days. ``PedometryBuffer``’s completion closure reports the results afther this many have been retrieved.
    let dayCount: Int
    
    private lazy var buffer: PedometryBuffer! = {
        let pBuffer = PedometryBuffer(capacity: 7) {
            data in
            let success = try! data.get()
            self.completion(ResultValue.success(success))
        }
        return pBuffer
    }()
    
    // MARK: Init
    /// Initialize with a count of days and completion callback once that many days are accounted for.
    ///
    /// Start the process by calling ``proceed()``.
    /// - Parameters:
    ///   - days: The number of days to query for and report
    ///   - callback: The closure that will receive the resulting CSV data.
    init(forDays days: Int,
         callback: @escaping ClosureType) {
        dayCount = days
        completion = callback
    }
    
    // MARK: Proceed
    /// Initiate the fetches for the past `dayCount` days.
    func proceed() {
        let predicates = predicates(count: dayCount)
        for predicate in predicates {
            execute(onePredicate: predicate)
        }
    }
    
    // MARK: Details
    
    private func dayLimits(_ count: Int = 7) -> [(Date, Date)] {
        let rightNow = Date()
        let lastMidnight = Self.gregorian.startOfDay(for: rightNow)
        let dayPairs = (0...count)
            .map {
                let previousDate =
                Self.gregorian.date(
                    byAdding: .day, value: -$0,
                    to: lastMidnight)!
                return previousDate
            }
            .reversed()
            .adjacentPairs()

        return Array(dayPairs)
    }
    
    /// Construct predicates for the daily step-count totals.
    /// - Parameter count: The number of daily predicates (and therefore days) to match.
    /// - Returns: `Array<NSPredicate>` containing query predicates for each of the past `count` days.
    private func predicates(count: Int = 7) -> [NSPredicate] {
        let pairs = dayLimits(count)
        let preds = pairs
            .map { (begin, end) in
                let query = HKQuery.predicateForSamples(withStart: begin, end: end,
                                                        options: [.strictEndDate, .strictStartDate])
                return query
            }
        return preds
    }
    
    /// Perform a query for a single day (single predicate).
    ///
    /// HealthKit will report the day's results through a completion function (``hkQueryCompletion(query:stats:error)``)
    /// - Parameter predicate: The selection predicate for a full day, midnight-to-midnight.
    private func execute(onePredicate predicate: NSPredicate) {
        let query = HKStatisticsQuery(
            quantityType: Self.hkStepsType,
            quantitySamplePredicate: predicate,
            
            options: .cumulativeSum,
            completionHandler: hkQueryCompletion(query:stats:error:))
        Self.store.execute(query)
    }
    
    /// Completion of a query counting steps for a single day.
    ///
    /// See the documentation for `HKStatisticsQuery` for a description of its completion closure.
    ///
    /// - If an error occurred, that is logged.
    /// - If no resulting statistics are found, log it and don't process this result.
    /// - If the statistics don't yeid the sum, log and exit.
    ///
    /// Incoming records are converted to ``StepsOnDate`` and inserted into the ``PedometryBuffer`` actor “`buffer`.”
    private func hkQueryCompletion(query: HKStatisticsQuery, stats: HKStatistics?, error: Error?) {
        // Error? Log, then proceed regardless.
        if let error {
            print("\(#function):\(#line) - query returned an error:", error)
        }
        // No result? Log and abandon the function.
        guard let stats else {
//            print("\(#function):\(#line) - Can't retrieve data for one day.")
            // TODO: Improve the log by giving the day or date
            return
        }
        
        // Can't get a sum of steps? Log and abandon.
        // TODO: make the `else` clause a fatal error.
        guard let sum = stats.sumQuantity() else {
            print("\(#function):\(#line) - Can't get sumQuantity from step stats..")
            return
        }
        let steps = sum.doubleValue(for: HKUnit.count())
        let start = stats.startDate
        
        let record = StepsOnDate(
            steps: Int(steps.rounded()),
            date: start)
        
        Task {
            await buffer.insert(datum: record)
        }
    }
}
