//
//  DASIQuestions.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/28/21.
//

import Foundation

// Question IDs run from 1 ... 12
// Array IDs run from 0..<12.

// MARK: - AnswerState
enum AnswerState: String, Codable, Equatable, CustomStringConvertible {
    case unknown, yes, no

    var description: String {
        switch self {
        case .no:       return "N"
        case .unknown:  return "•"
        case .yes:      return "Y"
        }
    }

    init?(described: String) {
        switch described {
        case "N":   self = .no
        case "•":   self = .unknown
        case "Y":   self = .yes
        default :   return nil
        }
    }
}

// MARK: - DASIQuestion
struct DASIQuestion: Identifiable, Codable, Comparable {
    var id: QuestionID
    let text: String
    let score: Double

    // WARNING: the ID is 1-based
    static let questions: [DASIQuestion] = {
        guard let dasiURL = Bundle.main.url(
            forResource: "DASIQuestions", withExtension: "json") else {
            preconditionFailure("Could not find DASIQuestions.json")
        }
        let dasiData = try! Data(contentsOf: dasiURL)
        let retval =  try! JSONDecoder().decode([DASIQuestion].self, from: dasiData)

        // Client code must set the upper bound for question indices to the number of elements read.
        QuestionID.questionCount = retval.count
        return retval
    }()

    static func with(id questionID: QuestionID) -> DASIQuestion {
        return questions[questionID.index]
    }

    static func == (lhs: DASIQuestion, rhs: DASIQuestion) -> Bool { lhs.id == rhs.id }
    static func <  (lhs: DASIQuestion, rhs: DASIQuestion) -> Bool { lhs.id <  rhs.id }
}

extension DASIQuestion {
    var next: DASIQuestion? {
        guard let proposed = id.succ,
              proposed.index < Self.questions.count else { return nil }
        return Self.with(id: proposed)
    }

    var previous: DASIQuestion? {
        guard let proposed = id.pred,
              proposed.isValid else {
            return nil
        }
        return Self.with(id: proposed)
    }
}
