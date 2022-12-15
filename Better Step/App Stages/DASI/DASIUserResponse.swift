//
//  DASIUserResponse.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/24/22.
//

import Foundation


// MARK: - DASIUserResponse
/// A response to a particular question, identified by the question's id (1-based), _not_ its index in the response array (0-based).
struct DASIUserResponse: Identifiable, Codable {
    let id: Int     // 1-based
    var response: AnswerState
    var timestamp: Date

    /// Initialize a `DASIUserResponse` from its attribute values.
    /// - Parameters:
    ///   - id: The ID for this questin (wrapped 1-base questionIndex)
    ///   - response: `yes`, `no`, or `unknown`
    init(id: Int,
         response: AnswerState = .unknown) {
        precondition(id > 0,
                     "id is supposed to be 1-based. The caller is in error for all question IDs, not just 0.")
        self.id = id
        self.response = response
        self.timestamp = Date()
    }

    /// The score the current response to thie question contributes to the overall score for the instrument.
    var score: Double {
        let question = DASIQuestion.with(id: self.id)
        return (response == .yes) ? question.score : 0
    }

    /// Pseudo-mutation by creating a new `DASIUserResponse` that' has the same values but for the response.
    /// - note: The result _must not_ be ignored. The returned value is a new `DASIUserResponse`.
    /// - Parameters:
    ///   - response: `yes`, `no`, or `unknown`.
    ///   - stamp: The time at which this was called, therefore the time a value was last generated. You are expected not to touch this parameter
    /// - Returns: A new `DASIRseponse` reflecting the new answer state.
    func withResponse(_ response: AnswerState) -> DASIUserResponse {
        DASIUserResponse(id: id,
                     response: response)
        // Timestamp updates in init()
    }
}

// MARK: - String representation
extension DASIUserResponse: Comparable, Hashable, CustomStringConvertible, CSVRepresentable {
    /// `Equatable` adoption
    static func == (lhs: DASIUserResponse, rhs: DASIUserResponse) -> Bool { lhs.id == rhs.id }
    /// `Comparable` adoption
    static func <  (lhs: DASIUserResponse, rhs: DASIUserResponse) -> Bool { lhs.id <  rhs.id }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(timestamp)
        hasher.combine(response)
    }

    /// Format the ID and response attributes into an array of `String`. Callers are expected to concatenate this array with global attributes: the subject ID and lhe time the CSV file was created.
    ///
    /// **See also** `DASIResponses.CSVDASIRecords`
    /// - note: ISO-8601 formatting is time-consuming,
    ///         but it'll be 16 times, once per run. No need to make
    ///         it `async`.
    var csvStrings: [String] {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = .withInternetDateTime
        return [
            timestamp.iso,
            String(describing: id),
            String(describing: response)
        ]
    }

    public var csvLine: String {
        self.response.description
    }

    /// `CustomStringConvertible` adoption
    var description: String {
        csvStrings.joined(separator: ",")
    }
}
