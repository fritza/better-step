//
//  QuestionID.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/25/22.
//

import Foundation
// Strideable -> Comparable -> Equatable
// Hashable -> Equatable
// If it's Hashable, you don't need equatable
// If it's strideable, you don't need Comparable or Equatable

// MARK: - QuestionID

extension Int {
    var qid: QuestionID {
        QuestionID(self)
    }

    var indexQID: QuestionID {
        QuestionID(index: self)
    }
}

/// The ID of a question. Its `rawValue` is the 1-based ID, _not_ its position in a question array.
///
/// `QuestionID`s come from storage as 1-based `Int`s. The `rawValue` is that 1-based index. Index `[Question]` with `self.index`.
///
/// This type uses `index` to refer to the equivalent zero-based value that would index into an `Array` of questions.
///
/// **Conforms to**
///
///* RawRepresentable,
///* Codable
///* Comparable
///* Hashable,
///* Strideable
///* CustomStringConvertible
///
/// - warning: Client code that populates `Array`s of questions (`DASIQuestion.questions` at this writing)) _must_ assign the count to `QuestionID.questionCount`.
public struct QuestionID: RawRepresentable, Codable,
                          Comparable,
                          Hashable, Strideable,
                          CustomStringConvertible,
                          CustomDebugStringConvertible,
Identifiable
{
    // MARK: Initialization
    public typealias Stride = Int

    /// The `QuestionID` that represents the _question number._ `init(rawValue:)` and `init(_:)` are equivalent.
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public init(_ value: Int) {
        self.init(rawValue: value)
    }

    /// Initialize from the equivalent index into a  `Collection`.
    ///
    /// This assumes the `Collection` is sorted uniformly by 1-based ID.
    public init(index: Int) { self.rawValue = index + 1 }
    /// The 0-based index at which this ID would appear in an `Array`, _assuming_ the array is ordered so that the `n`th `QuestionID` is sorted in order if `rawValue`.
    public var index: Int { self.rawValue - 1 }


    // MARK: Bounds
    static public var max: QuestionID {
        QuestionID(rawValue: questionCount)
        }
    static public var min: QuestionID {
        QuestionID(rawValue: 1)
    }

    // MARK: Strideable
    /// `Strideable`: The `QuestionID` the given `rawValue` before or after `self`.
    /// - warning: This does not guarantee the result is valid ((within  `(1...self.questionCount)`. To identify out-or-bounds results use `checkedAdance(by:)`, which returns `nil` if the result woild be out-of-bounds.
    public func advanced(by n: Int) -> QuestionID {
        return QuestionID(self.rawValue + 1)
    }

    /// `Strideable`: the amount by which  `self` must be advanced to match `other`.
    public func distance(to other: QuestionID) -> Int {
        other.rawValue - self.rawValue
    }

    /// `Strideable` **convenience**: Returns `advanced(by:)` if the result would be -in-bounds, `nil` if not.
    public func checkedAdance(by n: Int) -> QuestionID? {
        let unchecked = self.advanced(by: n)
        return unchecked.isValid ? unchecked : nil
    }

    /// The `QuestionID` next preceding `self`. Returns `nil` if that result would be out-of-bounds.
    public var pred: QuestionID? {
        return self.checkedAdance(by: -1)
    }

    /// The `QuestionID` nect following `self`. Returns `nil` if that result would be out-of-bounds.
    public var succ: QuestionID? {
        return self.checkedAdance(by:  1)
    }


    // MARK: Hashable, Equatable
    /// The upper limit of the open bounds of the index.
    ///
    /// Client code that populates the question list _must_ assign the count to this.
    static var questionCount = 12
    // FIXME: Stop using a constant for the count

    /// `Comparable`: ordering of two `QuestionID`s
    static public func < (lhs: QuestionID, rhs: QuestionID) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    /// `Equatable`: Matching two `QuestionID`s by `rawValue`.
    static public func == (lhs: QuestionID, rhs: QuestionID) -> Bool {
        lhs.rawValue == rhs.rawValue
    }

    // MARK: Identifiable
    public var id: Int { self.rawValue }

    // MARK: Hashable
    /// `Hashable`
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }


    /// `CustomStringConvertible`
    public var description: String { "QID(\(rawValue))" }
    public var debugDescription: String { "QuestionID(\(rawValue))" }

    /// Whether `self`'s `rawValue` faills within `(1...Self.questionCount)`
    ///
    /// If not, the ID does not correspond to a known question. Its `index` would point beyond the bounds of a question array.
    public var isValid: Bool {
        let retval = (1...Self.questionCount)
            .contains(rawValue)
        return retval
    }
}

// MARK: - DASIStages

/// Application of `QuestionID` to navigation through the stages of the DASI phase of the app. The intended use is a `@State` or a `@StateObject` property to be bound to the root survey view. The child views set the value, the root changes the view binding.
///
///
/// The values are:
///
/// - `.greeting`: Initial view; description and **Proceed** button.
/// -   `.completion`: The view indicating that all questions have been answered.
/// - `.presenting(question:)`: The survey-response view for the question with the auxiliary `QuestionID`
///
///- note: All references to DASI questions are by `QuestionID`.
enum DASIStages {
    // MARK: cases
    /// The pre-survey view
    case greeting
    /// The question being displayed as a `QuestionID`
    case presenting(question: QuestionID)
    /// The end-of-survey view.
    case completion

    // MARK: Question state
    /// If `self` is `.presenting(question:)` return the ID for the question being presented. If not, return `nil`.
    var questionID: QuestionID? {
        switch self {
        case .greeting, .completion: return nil
        case .presenting(question: let qid): return qid
        }
    }
    /// `false` iff the stage is `.greeting` or `.completion`,
    private var refersToQuestion: Bool {
        ![.greeting, .completion].contains(self)
    }

    // MARK: Arithmetic
    /// Mutate `self` to the stage before it. Return to `nil` if there is no preceding stage.
    ///
    /// `.greeting` has no effect. `.completion` backs off to the last of the `QuestionID`s. .`presenting(question:)` backs off to the previous question, or to .greeting if the QuestionID is at the minimum.
    @discardableResult
    mutating func goBack() -> DASIStages? {
        if !self.refersToQuestion { return nil }

        if case .presenting(let qid) = self  {
            self = .presenting(
                question:
                    qid.advanced(by: -1))
            return self
        }
        else { return nil }
    }
    #warning("Why does goBack mutate, but goForward doesn't?")

    /// Mutate `self` to the stage after it. Return to `nil` if there is no suceeding stage.
    ///
    /// `.completion` has no effect. `.greeting` advances to the first of the `QuestionID`s. .`presenting(question:)` advances to the next `QuestionID`, or to `.completion` if the `QuestionID` is at the maximum.
    func goForward() -> DASIStages? {
        switch self {
        case .greeting:
            return .presenting(question: 1.qid)
        case .completion:
            return nil
        case let .presenting(question: qid) where qid >= QuestionID.max:
            return .completion
        case let .presenting(question: qid):
            return .presenting(question: qid.succ!)
        }
    }

    @discardableResult
    mutating func advance() -> DASIStages {
        if let nextValue = self.goForward() {
            self = nextValue
        }
        return self
    }


    /// Set `self` to represent a given question.
    ///
    /// The jump is to `.presenting` states _only._ Out-of-range `QuestionID`s might return the nearest non-`.presenting` values, but this is not to be relied on.
    /// - Parameter question: The ID of the question to be represented. See the discussion for out-of-range IDs.
    /// - Returns: The represented `DASIStages` after the move.
    mutating func goTo(question: QuestionID) -> DASIStages {
        switch self {
        case .completion:
            break

        case .greeting:
            self = .presenting(question: .min)

        case .presenting(question: let qid)
            where qid <= .min:
            self = .greeting

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
        case .greeting: return "Greeting"
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
            (.greeting, .greeting):
            return true
        case (.presenting(question: let qidL), .presenting(question: let qidR)):
            return qidL == qidR
        default: return false
        }
    }

    static func < (lhs: DASIStages, rhs: DASIStages) -> Bool {
        if lhs == rhs { return false }

        switch (lhs, rhs) {
        case (.greeting, _) :
            // .greeting == .greeting already handled
            return true

        case (_, .completion):
            // .completion == .completion already handled
            return true

            // By here, both are SUPPOSED to be .presenting
        case (.presenting(question: let lhs),
                .presenting(question: let rhs)):
              return lhs < rhs

        default:
            assertionFailure("\(#function): unhandled case")
            return false
        }
    }

    // MARK: Hashable
    /// `Hashable` compliance
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .greeting: hasher.combine(0)
        case .completion: hasher.combine(1)
        case .presenting(question: let qid):
            hasher.combine(qid)
        }
    }
}
