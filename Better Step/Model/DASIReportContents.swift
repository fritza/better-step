//
//  DASIReportContents.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/24/22.
//

import Foundation
import Combine

/// The ID of a question. Its rawValue is that ID, _not_ its position in a question array.
struct QuestionID: RawRepresentable, Equatable, Comparable, Codable, Hashable, CustomStringConvertible {
    static func < (lhs: QuestionID, rhs: QuestionID) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    static func == (lhs: QuestionID, rhs: QuestionID) -> Bool {
        lhs.rawValue == rhs.rawValue
    }

    let rawValue: Int
    init(rawValue: Int) { self.rawValue = rawValue }
    init(index: Int) { self.rawValue = index + 1 }
    var index: Int { self.rawValue - 1 }

    func offset(by offset: Int) -> QuestionID? {
        let nextRawValue = rawValue + offset
        guard nextRawValue >= 0 else { return nil }
        return QuestionID(rawValue: nextRawValue)
    }

    var pred: QuestionID? {
        self.offset(by: -1)
    }
    var succ: QuestionID? {
        self.offset(by:  1)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }

    var description: String { "Qid: \(rawValue)" }
    var isValid: Bool { rawValue >= 1 }
}

// TODO: answers should never be empty.
//       if you need to empty it,
//       repopulate it with unresponded

final class DASIReportContents: ObservableObject {
    // TODO: Make a collection
    var subjectID: String?
//    public private(set) var timestamp: Date
    public private(set) var answers: [DASIResponse]

    init(forSubject subjectID: String? = nil) {
        self.subjectID = subjectID
//        self.timestamp = Date()
        self.answers   = DASIQuestion
            .questions
            .map { DASIResponse(id: $0.id, response: .unknown) }
    }

    func responseForQuestion(id: QuestionID) -> AnswerState {
        precondition(id.isValid)

        guard let theResponse = answers.first(where: {
            // Question ID starts from 1
            $0.id == id }) else {
                return .unknown
            }
        return theResponse.response
    }

    func didRespondToQuestion(
        id questionID: QuestionID,
        with state: AnswerState) {
            answers[questionID.index]
            = answers[questionID.index]
                .withResponse(state)
        }

    var emptyResponseIDs: [QuestionID] {
       return answers
            .filter { $0.response == .unknown }
            .map(\.id)
    }

    func resetQuestion(questionID: QuestionID) {
        let newValue = answers[questionID.index]
            .withResponse(.unknown)
        answers[questionID.index] = newValue
    }

    func reset() {
        let result = answers.map {
            $0.withResponse(.unknown)
        }
        self.answers = result
    }

    var CSVDASIRecords: String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = .withInternetDateTime

        let prefix = [subjectID ?? "n/a", isoFormatter.string(from: Date())
                      ]
        let eachLine = answers
            .flatMap {
                prefix + $0.csvStrings
            }
        let allLines = eachLine
            .joined(separator: ",")
        return allLines
    }
}
