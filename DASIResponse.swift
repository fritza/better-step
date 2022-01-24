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

    init(id: QuestionID,
         response: AnswerState = .unknown,
         timestamp: Date = Date()) {
        self.id = id
        self.response = response
        self.timestamp = timestamp
    }

    var score: Double {
        let question = DASIQuestion.with(id: self.id)
        return (response == .yes) ? question.score : 0
    }

    func withResponse(_ response: AnswerState,
                      at stamp: Date = Date()) -> DASIResponse {
        DASIResponse(id: id,
                     response: response,
                     timestamp: stamp)
    }
}

// MARK: - String representation
extension DASIResponse: Comparable, CustomStringConvertible {
    static func == (lhs: DASIResponse, rhs: DASIResponse) -> Bool { lhs.id == rhs.id }
    static func <  (lhs: DASIResponse, rhs: DASIResponse) -> Bool { lhs.id <  rhs.id }

    var csvStrings: [String] {
        [String(describing: id),
         String(describing: response)
         ]
    }
    /*
     let responseItems =
         surveyResults
             .map { (result) -> String in
                 return "\(result.question_number),\(result.response ? "Y" : "N")"
     }
     let allItems = [subjectItem] + [dateItem] + responseItems

     */
    // subject, date, response

    var description: String {
        csvStrings.joined(separator: ",")
    }
}
