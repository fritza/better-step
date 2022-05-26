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
/// - note: `DASIQuestionState` and `AnswerState` are meant to be immutable. Audit the code to make sure of it.
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
}

// Verified consistent with DASIQuestions in the MinutePublisher.playground/Response\ decoding.
// TODO: Validate that this is immutable.
//       It just orders questions and provides
//       lookup.
// MARK: - DASIQuestionState
/// A question in the DASI set, loaded from `DASIQuestions.json`, with id, question text, and the score assigned to "Yes"
///
/// `id` is the 1-based enumeration of the question, not its position in the array. Lookups search the `questions` array for a matching `id`. The array _needn't_ be in any particular order.
/// - note: `DASIQuestionState` and `AnswerState` are meant to be immutable. Audit the code to make sure of it.
public struct DASIQuestionState: Identifiable, Codable, Comparable {
    static let jsonBasename = "DASIQuestions"

    // TODO: Consider making this into a Collection
    public var id   : Int       // 1-based
    public let text : String
    public let score: Double

    // WARNING: the ID is 1-based
    public static let questions: [DASIQuestionState] = {
        guard let dasiURL = Bundle.main.url(
            forResource: Self.jsonBasename, withExtension: "json") else {
                preconditionFailure("Could not find DASIQuestions.json")
            }
        let dasiData = try! Data(contentsOf: dasiURL)
        let retval =  try! JSONDecoder().decode([DASIQuestionState].self, from: dasiData)
        return retval
    }()

    /// Number of questions in the survey
    public static var count: Int { questions.count }
    public static var cdCount: Int { DASIQuestion.count() }

    /// The question with the given ID.
    /// - precondition: ID out-of-range is a fatal error.
    public static func with(id soughtID: Int) -> DASIQuestionState {
        guard let retval = questions.first(where: { question in
            question.id == soughtID
        })
        else { fatalError("question ID \(soughtID) sought, not found") }
        return retval
    }

    // MARK: Comparable cmopliance
    public static func == (lhs: DASIQuestionState, rhs: DASIQuestionState) -> Bool { lhs.id == rhs.id }
    public static func <  (lhs: DASIQuestionState, rhs: DASIQuestionState) -> Bool { lhs.id <  rhs.id }
}

extension DASIQuestionState {
    /// The question whose `id` comes after `self`'s `id.
    ///
    /// Does not mutate.
    /// - returns: the succeeding `DASIQuestionState`, or `nil` if there is no question in range.
    public var next: DASIQuestionState? {
        let proposedQuestionID = id + 1
        guard DASIStages.indexRange.contains(proposedQuestionID) else { return nil }
        return Self.with(id: proposedQuestionID)
    }

    /// The question whose `id` comes before `self`'s `id.
    ///
    /// Does not mutate.
    /// - returns: the preceding `DASIQuestionState`, or `nil` if there is no question in range.
    public var previous: DASIQuestionState? {
        let proposedQuestionID = id - 1
        guard DASIStages.indexRange.contains(proposedQuestionID) else { return nil }
        return Self.with(id: proposedQuestionID)
    }

    // CORE DATA equivalent:

    public var cdNext: DASIQuestionState? {
        let cdRetval: DASIQuestion? =
        DASIQuestion.fetchOne(withTemplate: "withQuestionID",
                              params: ["QUESTIONNUMBER": (id + 1) as NSNumber])
        guard let cdQuestion = cdRetval, let text = cdRetval?.text else { return nil }
        return DASIQuestionState(id: numericCast(cdQuestion.number),
                                 text: text, score: Double(cdQuestion.score))
    }

    public var cdPrevious: DASIQuestionState? {
        let cdRetval: DASIQuestion? =
        DASIQuestion.fetchOne(withTemplate: "withQuestionID",
                              params: ["QUESTIONNUMBER": (id - 1) as NSNumber])
        guard let cdQuestion = cdRetval, let text = cdRetval?.text else { return nil }
        return DASIQuestionState(id: numericCast(cdQuestion.number),
                                 text: text, score: Double(cdQuestion.score))
    }

    public static let cdQuestions: [DASIQuestionState] = {
        let allCDQuestions: [DASIQuestion] = DASIQuestion.all().sorted { $0.id < $1.id }
        return allCDQuestions
            .compactMap { (cdq: DASIQuestion) -> DASIQuestionState? in
                guard let text = cdq.text else { return nil }
                return DASIQuestionState(id: numericCast(cdq.number),
                                         text: text, score: Double(cdq.score))
            }
    }()

}
