//
//  DASIStages.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/8/22.
//

import Foundation

// MARK: - DASIStages

/*
 Legitimacy of yse of DASIStages:

 In general, the constants for indices and bounds.

 ??
    question identifier
    refers to question?

 */


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
    // ~Index represents place in the questions array.
    // These are guaranteed to be valid, as they rely on the range of array indices, not the identifiers.
    static let startIndex = 0
    static let endIndex   = DASIQuestion.questions.count
    static let indexRange = (startIndex ..< endIndex)

    // min and max denote least and greatest valid .presenting question identifiers.
    // WARNING: These assume the identifers are numbered 1...answer count.


    static let minIdentifier   = startIndex + 1
    static let maxIdentifier   = endIndex
    static let minPresenting   = DASIStages.presenting(
        questionID: minIdentifier)
    static let maxPresenting   = DASIStages.presenting(
        questionID: maxIdentifier)

    // MARK: cases
    /// The pre-survey view
    case landing
    /// The question being displayed as a `QuestionID`
    case presenting(questionID: Int)
    /// The end-of-survey view.
    case completion

    // MARK: Arithmetic

    /// Mutate `self` to the stage before it. Return to `nil` if there is no preceding stage.
    ///
    /// `.landing` has no effect. `.completion` backs off to the last of the `QuestionID`s. .`presenting(question:)` backs off to the previous question, or to .landing if the QuestionID is at the minimum.
    @discardableResult
    mutating func decremented() -> DASIStages {
        let retval: DASIStages
        switch self {
        case .landing:
            retval = .landing
        case Self.minPresenting:
            retval = .landing
        case let .presenting(questionID: qid):
            retval = .presenting(questionID: qid-1)
        case .completion:
            retval = Self.maxPresenting
        }
        self = retval
        return retval
    }

    /// Mutate `self` to the stage after it. Return to `nil` if there is no suceeding stage.
    ///
    /// `.completion` has no effect. `.landing` advances to the first of the `QuestionID`s. .`presenting(questionID:)` advances to the next `QuestionID`, or to `.completion` if the `QuestionID` is at the maximum.
    @discardableResult
    mutating func incremented() -> DASIStages {
        let retval: DASIStages
        switch self {
        case .landing:
            retval = Self.minPresenting
        case .completion:
            retval = .completion
        case Self.maxPresenting:
            retval = .completion
        case let .presenting(questionID: idx):
            retval = .presenting(questionID: idx + 1)
        }
        self = retval
        return retval
    }
}


// MARK: CustomStringConvertible
extension DASIStages: CustomStringConvertible {
    /// `CustomStringConvertible` comlpliance
    var description: String {
        switch self {
        case .landing: return "Greeting"
        case .completion: return "Completion"
        case .presenting(questionID: let q):
            return "Presenting ID \(q)"
        }
    }
}

extension DASIStages: Comparable, Hashable, Strideable
{
    // MARK: - Equatable
    /// Protocol compliance
    static func == (lhs: DASIStages, rhs: DASIStages) -> Bool {
        switch (lhs, rhs) {
        case (.completion, .completion),
            (.landing, .landing):
            return true
        case (.presenting(questionID: let qidL),
                .presenting(questionID: let qidR)):
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
        case (.presenting(questionID: let lhs),
                .presenting(questionID: let rhs)):
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
        case .presenting(questionID: let qid):
            hasher.combine(qid + 1000)
        }
    }

    // MARK: Strideable
    /// `Strideable` compliance.
    func advanced(by n: Int) -> DASIStages {
        // n > 0
        var retval: DASIStages = self

        if n == 0 { return self }
        else if n > 0 {
            for _ in (1...n) {
                retval.incremented()
            }
            return retval
        }
        else {
            for _ in 1...n {
                retval.decremented()
            }
            return retval
        }
    }

    /// `Strideable` compliance.
    func distance(to other: DASIStages) -> Int {
        if self == other { return 0 }

        var retval = 0
        var cursor = self
        if other < self {
            while cursor > other {
                cursor.decremented()
                retval -= 1
            }
        }
        else if other > self {
            while cursor > other {
                cursor.incremented()
                retval += 1
            }
        }
        return retval
    }
}
