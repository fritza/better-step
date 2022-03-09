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
/// Yes, No, or Unknown state, usually for recording the user's response to ta question
///
/// `.unknown`, therefore, represents a question not yet answered.
enum AnswerState: String, Codable, Equatable, CustomStringConvertible {
    case unknown, yes, no

    /// `CustomStringConvertible` adoption. Single-character `String`,  "•",  "Y", "N"
    var description: String {
        switch self {
        case .no:       return "N"
        case .unknown:  return "•"
        case .yes:      return "Y"
        }
    }

    /// Inverse of `description`. These must match case and content with  "•",  "Y", or "N". Otherwise initialization fails.
    init?(described: String) {
        switch described {
        case "N":   self = .no
        case "•":   self = .unknown
        case "Y":   self = .yes
        default :   return nil
        }
    }

    /// Conversion from a yes-no button stack `YesNoStack` ID to `.yes` or `.no`.
    ///
    /// Fails (`nil`) if `btnNum` isn't 1 or 2. For debug builds, asserts.
    init?(fromYNButtonNumber btnNum: Int) {
        switch btnNum {
        case 1: self = .yes
        case 2: self = .no
        default:
            assertionFailure("Got y/n response of \(btnNum)")
            return nil
        }
    }

    /// Inverse of `init?(fromYNButtonNumber:)` `.unknown` decodes as 0.
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
/// A question in the DASI set, loaded from `DASIQuestions.json`, with id, question text, and the score assigned to "Yes"
///
/// `id` is the 1-based enumeration of the question, not its position in the array. Lookups search the `questions` array for a matching `id`. The array _needn't_ be in any particular order.
public struct DASIQuestion: Identifiable, Codable, Comparable {
    static let jsonBasename = "DASIQuestions"

    // TODO: Consider making this into a Collection
    public var id   : Int       // 1-based
    public let text : String
    public let score: Double

    // WARNING: the ID is 1-based
    public static let questions: [DASIQuestion] = {
        guard let dasiURL = Bundle.main.url(
            forResource: Self.jsonBasename, withExtension: "json") else {
                preconditionFailure("Could not find DASIQuestions.json")
            }
        let dasiData = try! Data(contentsOf: dasiURL)
        let retval =  try! JSONDecoder().decode([DASIQuestion].self, from: dasiData)
        return retval
    }()

    public static var count: Int { questions.count }

    /// The question with the given ID.
    /// - precondition: ID out-of-range is a fatal error.
    public static func with(id soughtID: Int) -> DASIQuestion {
        guard let retval = questions.first(where: { question in
            question.id == soughtID
        })
        else { fatalError("question ID \(soughtID) sought, not found") }
        return retval
    }

    // MARK: Comparable cmopliance
    public static func == (lhs: DASIQuestion, rhs: DASIQuestion) -> Bool { lhs.id == rhs.id }
    public static func <  (lhs: DASIQuestion, rhs: DASIQuestion) -> Bool { lhs.id <  rhs.id }
}

extension DASIQuestion {
    /// The question whose `id` comes after `self`'s `id.
    ///
    /// Does not mutate.
    /// - returns: the succeeding `DASIQuestion`, or `nil` if there is no question in range.
    public var next: DASIQuestion? {
        guard let proposed = id.succ,
              proposed.index < Self.count else { return nil }
        return Self.with(id: proposed)
    }

    /// The question whose `id` comes before `self`'s `id.
    ///
    /// Does not mutate.
    /// - returns: the preceding `DASIQuestion`, or `nil` if there is no question in range.
    public var previous: DASIQuestion? {
        guard let proposed = id.pred,
              proposed.isValid else {
            return nil
        }
        return Self.with(id: proposed)
    }
}
