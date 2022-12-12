//
//  CSVRendering.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/8/22.
//

import Foundation

// NOT USED
extension Array where Element: CSVRepresentable {
    func headerPrefixed(headers: [String]? = nil) -> [String] {
        guard !isEmpty else { return [] }

        var mutableOperands = self

        let firstString: String
        if let headers { firstString = headers.csvLine }
        else { firstString = mutableOperands.removeFirst().csvLine }

        let retval = mutableOperands.reduce(into: [firstString]) {
            $0.append($1.csvLine)
        }
        return retval
    }
}

// NOT USED
struct TransmissionFormatter {
                 let taskTag         : String
                 let subjectIDString : String
    private(set) var timeOffset      : TimeInterval!
                 let hasLeadingTime  : Bool
                 let headers         : [String]

// the timestamp is the


    // NOT USED
    init(tag: String, subjectID: String, timestampPresent: Bool,
         headers headerArray: [String] = []) {
        (taskTag, subjectIDString, hasLeadingTime, headers) =
        (tag, subjectID, timestampPresent, headerArray)

        // nil timeOffset is supposed to be a way to capture the
        // time interval on first use.
        // I'd like to capture it from the raw array of String,
        // but I'd like to see if I can rely on the index.

        // You get the uniform tag and ID (not required for input, they're constant paroperties.)
        // The _time_ varies from record to record. We'd preder not to rely on the
        // ordering of the data line. CMLog carries a timestamp. the CSV representation
        // includes the stamp value.
    }

    // NOT USED
    mutating func format<CSVR>(dataLine: [CSVR]) -> String?
    where CSVR: CSVRepresentable
    {
        guard !dataLine.isEmpty else { return nil }

        var workingDataLine = dataLine
        // Suppose you can rely on the leading element in dataLine is a timestamp.
        if hasLeadingTime, let leadingValue = workingDataLine.removeFirst() as? TimeInterval {
            timeOffset = timeOffset ?? leadingValue
        }


        // Nooo… you don't ascertain whether the datum has a timestamp at all.

        return ""
    }
}

extension Array {
    // NOT USED

    /// Set a property of the members of the `Element`s of an `Array`
    /// - Parameters:
    ///   - path: A  keypath identifying the property to be edited.
    ///   - mod: A closure that provides the substitute for each element.
    /// - Returns: This `Array` with the elements altered according to `mod`.
    func tinker<T>(
        path: WritableKeyPath<Element, T>,
        mod: (T) -> T) -> [Element]
    {
        let r = self
            .map {
                element in
                var deltableEL = element
                deltableEL[keyPath: path] = mod( element[ keyPath: path ] )
                return deltableEL
            }
        return r
    }
}


// leave-
// fd4f1578760b5c392848-
// fe6812727764077d7217-
// fefe1376746704-
// fe3811737164047e751371-
// ff331770746c
// @leave.e.charitynavigator.org


/*
 What I'd like to have is to assemble CSV file contents from CSVRepresentable records.

 We know we can expect headers.

 The output spec is to include the top, header line.

 One problem: Some representables include a time stamp, some do not.

 But I'd like to have a uniform time stamp.
 - Has no timestamp, give time = 0.
 - Has a timestamp, use the time
    - Nice to have: time from beginning of the exercise (iow, the first sample is at 0.00000, second is at 0.01667…
    - Format all pointFour.
 - See XYZ.swift ->  CSVFileRepresentable.headerPrefixed
 */





