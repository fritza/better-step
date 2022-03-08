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

    init?(fromYNButtonNumber btnNum: Int) {
        switch btnNum {
        case 1: self = .yes
        case 2: self = .no
        default:
            assertionFailure("Got y/n response of \(btnNum)")
            return nil
        }
    }

    var ynButtonNumber: Int {
        switch self {

        case .unknown:
            return 0
        case .yes:
            return 1
        case .no:
            return 2
        }
    }
}

// Verified consistent with DASIQuestions in the MinutePublisher.playground/Response\ decoding.
// MARK: - DASIQuestion
public struct DASIQuestion: Identifiable, Codable, Comparable {
    // TODO: Consider making this into a Collection
    public var id: QuestionID
    public let text: String
    public let score: Double

    // WARNING: the ID is 1-based
    public static let questions: [DASIQuestion] = {
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

    public static var count: Int { questions.count }

    public static func with(id questionID: QuestionID) -> DASIQuestion {
        return questions[questionID.index]
    }

    public static func == (lhs: DASIQuestion, rhs: DASIQuestion) -> Bool { lhs.id == rhs.id }
    public static func <  (lhs: DASIQuestion, rhs: DASIQuestion) -> Bool { lhs.id <  rhs.id }
}

extension DASIQuestion {
    public var next: DASIQuestion? {
        guard let proposed = id.succ,
              proposed.index < Self.count else { return nil }
        return Self.with(id: proposed)
    }

    public var previous: DASIQuestion? {
        guard let proposed = id.pred,
              proposed.isValid else {
            return nil
        }
        return Self.with(id: proposed)
    }
}
