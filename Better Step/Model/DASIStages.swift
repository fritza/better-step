//
//  DASIStages.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/8/22.
//

import Foundation

// MARK: - DASIStages

/// Application of `QuestionID` to navigation through the stages of the DASI phase of the app. The intended use is a `@State` or a `@StateObject` property to be bound to the root survey view. The child views set the value, the root changes the view binding.
///
///
/// The values are:
///
/// - `.landing`: Initial view; description and **Proceed** button.
/// -   `.completion`: The view indicating that all questions have been answered.
/// - `.presenting(questionID:)`: The survey-response view for the question with the 1-based question identifier.
///
///- note: All references to DASI questions are by `QuestionID`.
enum DASIStages {
    // MARK: cases
    /// The pre-survey view
    case landing
    /// The question being displayed as a `QuestionID`
    case presenting(question: QuestionID)
    /// The end-of-survey view.
    case completion

    // MARK: Question state
    /// If `self` is `.presenting(question:)` return the ID for the question being presented. If not, return `nil`.
    var questionID: QuestionID? {
        switch self {
        case .landing, .completion: return nil
        case .presenting(question: let qid): return qid
        }
    }
    /// `false` iff the stage is `.landing` or `.completion`,
    var refersToQuestion: Bool {
        ![.landing, .completion].contains(self)
    }

    // MARK: Arithmetic

    static let maxPresenting = DASIStages.presenting(question: QuestionID.max)
    static let minPresenting = DASIStages.presenting(question: QuestionID.min)

    /// Mutate `self` to the stage before it. Return to `nil` if there is no preceding stage.
    ///
    /// `.landing` has no effect. `.completion` backs off to the last of the `QuestionID`s. .`presenting(question:)` backs off to the previous question, or to .landing if the QuestionID is at the minimum.
    @discardableResult
    mutating func goBack() -> DASIStages {
        let retval: DASIStages
        switch self {
        case .landing:
            retval = .landing
        case let .presenting(question: qid)
            where qid == QuestionID.min:
            retval = .landing
        case let .presenting(question: qid):
            retval = .presenting(question: qid.pred!)
        case .completion:
            retval = .presenting(question: QuestionID.max)
        }
        self = retval
        return retval
    }
    #warning("Why does goBack mutate, but goForward doesn't?")
    @discardableResult
    mutating func retreat() -> DASIStages {
        return self.goBack()
    }


    /// Mutate `self` to the stage after it. Return to `nil` if there is no suceeding stage.
    ///
    /// `.completion` has no effect. `.landing` advances to the first of the `QuestionID`s. .`presenting(questionID:)` advances to the next `QuestionID`, or to `.completion` if the `QuestionID` is at the maximum.
    @discardableResult
    mutating func goForward() -> DASIStages {
        let retval: DASIStages
        switch self {
        case .landing:
            retval = .presenting(question: 1.qid)
        case .completion:
            retval = .completion
        case let .presenting(question: qid) where qid >= QuestionID.max:
            retval = .completion
        case let .presenting(question: qid):
            retval = .presenting(question: qid.succ!)
        }
        self = retval
        return retval
    }

    @discardableResult
    mutating func advance() -> DASIStages {
        return self.goForward()
    }


    /// Set `self` to represent a given question, by 1-based id.
    ///
    /// The jump is to `.presenting` states _only._
    /// - Parameter questionID: The ID (1-based) of the question to be represented.
    /// - precondition: The index must be in the range of question identifiers.
    /// - Returns: The represented `DASIStages` after the move.
    mutating func goTo(question: QuestionID) -> DASIStages {
        switch self {
        case .completion:
            break

        case .landing:
            self = .presenting(question: .min)

        case .presenting(question: let qid)
            where qid <= .min:
            self = .landing

        case .presenting(question: let qid)
            where qid >= .max:
            self = .completion

        case .presenting(question: _):
            self = .presenting(question: question)
        }
        return self
    }
}

extension DASIStages: CustomStringConvertible {
    var description: String {
        switch self {
        case .landing: return "Greeting"
        case .completion: return "Completion"
        case .presenting(question: let q):
            return "Presenting ID \(q)"
        }
    }
}

extension DASIStages: Comparable, Hashable {
    // MARK: - Equatable
    /// Protocol compliance
    static func == (lhs: DASIStages, rhs: DASIStages) -> Bool {
        switch (lhs, rhs) {
        case (.completion, .completion),
            (.landing, .landing):
            return true
        case (.presenting(question: let qidL), .presenting(question: let qidR)):
            return qidL == qidR
        default: return false
        }
    }

    static func < (lhs: DASIStages, rhs: DASIStages) -> Bool {
        if lhs == rhs { return false }

        switch (lhs, rhs) {
            // (.landing, .landing) taken care first line
        case (.landing, _)   : return true
        case (_, .landing)   : return false

            // (.completion, .completion) taken care first line
        case (_, .completion): return true
        case (.completion, _): return false

            // By here, both are SUPPOSED to be .presenting
        case (.presenting(question: let lhs),
                .presenting(question: let rhs)):
              return lhs < rhs

        default:
            fatalError("\(#function): unhandled case")
        }
    }

    // MARK: Hashable
    /// `Hashable` compliance
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .landing: hasher.combine(0)
        case .completion: hasher.combine(1)
        case .presenting(question: let qid):
            hasher.combine(qid)
        }
    }


}
