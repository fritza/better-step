//
//  DASIResponse.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/24/22.
//

import Foundation


// MARK: - DASIResponse
struct DASIResponse: Identifiable, Codable {
    typealias ID = QuestionID
    let id: QuestionID
    var response: AnswerState
    var timestamp: Date

    /// Initialize a `DASIResponse` from its attribute values.
    /// - Parameters:
    ///   - id: The ID for this questin (wrapped 1-base index)
    ///   - response: `yes`, `no`, or `unknown`
    init(id: QuestionID,
         response: AnswerState = .unknown) {
        self.id = id
        self.response = response
        self.timestamp = Date()
    }

    /// The score the current response to thie question contributes to the overall score for the instrument.
    var score: Double {
        let question = DASIQuestion.with(id: self.id)
        return (response == .yes) ? question.score : 0
    }

    /// Pseudo-mutation by creating a new `DASIResponse` that' has the same values but for the response.
    /// - Parameters:
    ///   - response: `yes`, `no`, or `unknown`.
    ///   - stamp: The time at which this was called, therefore the time a value was last generated. You are expected not to touch this parameter
    /// - Returns: A new `DASIRseponse` reflecting the new answer state.
    func withResponse(_ response: AnswerState) -> DASIResponse {
        DASIResponse(id: id,
                     response: response)
        // Timestamp updates in init()
    }
}

// MARK: - String representation
extension DASIResponse: Comparable, CustomStringConvertible {
    /// `Equatable` adoption
    static func == (lhs: DASIResponse, rhs: DASIResponse) -> Bool { lhs.id == rhs.id }
    /// `Comparable` adoption
    static func <  (lhs: DASIResponse, rhs: DASIResponse) -> Bool { lhs.id <  rhs.id }

    /// Format the ID and response attributes into an array of `String`. Callers are expected to concatenate this array with global attributes: the subject ID and lhe time the CSV file was created.
    ///
    /// **See also** `DASIReportContents.CSVDASIRecords`
    var csvStrings: [String] {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = .withInternetDateTime
        return [
            isoFormatter.string(from: timestamp),
            String(describing: id),
            String(describing: response)
        ]
    }

    /// `CustomStringConvertible` adoption
    var description: String {
        csvStrings.joined(separator: ",")
    }
}
