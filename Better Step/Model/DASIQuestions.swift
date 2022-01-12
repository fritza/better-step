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
    let id: Int
    let text: String
    let score: Double
    let identifier: String  // Not used

    // WARNING: the ID is 1-based
    static let questions: [DASIQuestion] = {
        guard let dasiURL = Bundle.main.url(
            forResource: "DASIQuestions", withExtension: "json") else {
            preconditionFailure("Could not find DASIQuestions.json")
        }
        let dasiData = try! Data(contentsOf: dasiURL)
        let retval =  try! JSONDecoder().decode([DASIQuestion].self, from: dasiData)
        return retval
    }()
    #warning("Check index versus ID.")
    static func with(id questionID: Int) -> DASIQuestion {
        return questions[questionID-1]
    }

    static func == (lhs: DASIQuestion, rhs: DASIQuestion) -> Bool { lhs.id == rhs.id }
    static func <  (lhs: DASIQuestion, rhs: DASIQuestion) -> Bool { lhs.id <  rhs.id }
}

extension DASIQuestion {
    var next: DASIQuestion? {
        let proposed = id + 1
        guard proposed < Self.questions.count else {
            return nil
        }
        return Self.with(id: proposed)
    }

    var previous: DASIQuestion? {
        let proposed = id - 1
        guard proposed >= 1 else {
            return nil
        }
        return Self.with(id: proposed)
    }
}

// MARK: - DASIResponse
struct DASIResponse: Identifiable, Codable {
    let id: Int
    let response: AnswerState

    var score: Double {
        let question = DASIQuestion.with(id: self.id)
        return (response == .yes) ? question.score : 0
    }

    static let emptyResponses: [DASIResponse] = {
        let retval =  DASIQuestion.questions
            .map { DASIResponse(id: $0.id, response: .unknown) }

        return retval
    }()
}

// MARK: - String representation
extension DASIResponse: Comparable, CustomStringConvertible {
    static func == (lhs: DASIResponse, rhs: DASIResponse) -> Bool { lhs.id == rhs.id }
    static func <  (lhs: DASIResponse, rhs: DASIResponse) -> Bool { lhs.id <  rhs.id }

    var csvStrings: [String] {
        [ String(id), "\(response)" ]
    }

    var description: String {
        csvStrings.joined(separator: ",")
    }
}
