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
/// - note: `DASIQuestion` and `AnswerState` are meant to be immutable. Audit the code to make sure of it.
enum AnswerState: String, Codable, Equatable, CustomStringConvertible, CSVRepresentable {
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

    // TODO: wise to have a special-case property for `YesNoStack`?
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

    public var csvLine: String {
        self.description
    }
}

// Verified consistent with DASIQuestions in the MinutePublisher.playground/Response\ decoding.
// TODO: Validate that this is immutable.
//       It just orders questions and provides
//       lookup.
// MARK: - DASIQuestion
/// A question in the DASI set, loaded from `DASIQuestions.json`, with id, question text, and the score assigned to "Yes"
///
/// `id` is the 1-based enumeration of the question, not its position in the array. Lookups search the `questions` array for a matching `id`. The array _needn't_ be in any particular order.
/// - note: `DASIQuestion` and `AnswerState` are meant to be immutable. Audit the code to make sure of it.
public struct DASIQuestion: Identifiable, Codable, Comparable {
    static let jsonBasename = "DASIQuestions"

    // TODO: Consider making this into a Collection
    /// The 1-based identifier for the question
    public var id   : Int       // 1-based
    /// The content for the question (Can you…?)
    public let text : String
    /// The DASI-scale score for answering **yes**.
    public let score: Double

    // WARNING: the ID is 1-based
    /// All `DASIQuestions` read froom `(jsonBasename).json`
    /// as a zero-indexed array. Be careful of mixing array-indexing and item ID.
    public static let questions: [DASIQuestion] = {
        guard let dasiURL = Bundle.main.url(
            forResource: Self.jsonBasename, withExtension: "json") else {
                preconditionFailure("Could not find DASIQuestions.json")
            }
        let dasiData = try! Data(contentsOf: dasiURL)
        let retval =  try! JSONDecoder().decode([DASIQuestion].self, from: dasiData)
        return retval
    }()

    /// Number of questions in the survey
    public static var count: Int { questions.count }

    /// The `DASIQuestion` with the given ID in the global `questions` collection.
    /// - parameter souughtID: The one-based identifier for the desired question.
    /// - precondition: ID out-of-range is a fatal error.
    public static func with(id soughtID: Int) -> DASIQuestion {
        guard let retval = questions.first(where: { question in
            question.id == soughtID
        })
        else { fatalError("question ID \(soughtID) sought, not found") }
        return retval
    }

    // MARK: Comparable compliance
    public static func == (lhs: DASIQuestion, rhs: DASIQuestion) -> Bool { lhs.id == rhs.id }
    public static func <  (lhs: DASIQuestion, rhs: DASIQuestion) -> Bool { lhs.id <  rhs.id }
}

extension DASIQuestion {
    /// The question whose `id` comes after `self`'s `id.
    ///
    /// Does not mutate.
    /// - returns: the succeeding `DASIQuestion`, or `nil` if there is no question in range.
    public var next: DASIQuestion? {
        let proposedQuestionID = id + 1
        guard DASIStages.indexRange.contains(proposedQuestionID) else { return nil }
        return Self.with(id: proposedQuestionID)
    }

    /// The question whose `id` comes before `self`'s `id.
    ///
    /// Does not mutate.
    /// - returns: the preceding `DASIQuestion`, or `nil` if there is no question in range.
    public var previous: DASIQuestion? {
        let proposedQuestionID = id - 1
        guard DASIStages.indexRange.contains(proposedQuestionID) else { return nil }
        return Self.with(id: proposedQuestionID)
    }
}
