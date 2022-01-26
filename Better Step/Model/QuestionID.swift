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

/// The ID of a question. Its `rawValue` is the 1-based ID, _not_ its position in a question array.
///
/// `QuestionID`s come from storage as 1-based `Int`s. The `rawValue` is that 1-based index. Index `[Question]` with `self.index`.
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
                   Hashable, Strideable,
                   CustomStringConvertible,
                   CustomDebugStringConvertible
{
    public typealias Stride = Int

    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }

    /// Initialize from the equivalend index into a  `Collection`.
    ///
    /// This assumes the `Collection` is sorted uniformlty by 1-based ID.
    public init(index: Int) { self.rawValue = index + 1 }
    /// The 0-based index at which this ID would appear in an `Array`, _assuming_ the array is ordered so that the `n`th `QuestionID` is sorted in order if `rawValue`.
    public var index: Int { self.rawValue - 1 }

    /// The upper limit of the open bounds of the index.
    ///
    /// Client code that populates the question list _must_ assign the count to this.
    static var questionCount = 12

    /// `Comparable`: ordering of two `QuestionID`s
    static public func < (lhs: QuestionID, rhs: QuestionID) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    /// `Equatable`: Matching two `QuestionID`s by `rawValue`.
    static public func == (lhs: QuestionID, rhs: QuestionID) -> Bool {
        lhs.rawValue == rhs.rawValue
    }

    /// `Strideable`: The `QuestionID` the given `rawValue` before or after `self`.
    /// - warning: This does not guarantee the result is valid ((within  `(1...self.questionCount)`. To identify out-or-bounds results use `checkedAdance(by:)`, which returns `nil` if the result woild be out-of-bounds.
    public func advanced(by n: Int) -> QuestionID {
        return QuestionID(rawValue: self.rawValue + 1)
    }

    /// `Strideable`: the amount by which  `self` must be advanced to match `other`.
    public func distance(to other: QuestionID) -> Int {
        other.rawValue - self.rawValue
    }

    /// `Strideable` **convenience**: Returns `advanced(by:` if the result would be -in-bounds, `nil` if not.
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

    /// `Hashable`
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }

    /// `CustonStringConvertibla`
    public var description: String { "\(rawValue)" }
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
