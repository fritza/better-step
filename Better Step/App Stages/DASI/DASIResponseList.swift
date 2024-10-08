//
//  DASIResponseList.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/24/22.
//

import Foundation
import Combine
import UniformTypeIdentifiers
import SwiftUI

/**
 # Theory behind DASI reporting.

 ## Primitive data structures

 ### struct DASIQuestion

 * Questions as such: Text, ID, and scoring.
 * The literature identifies questions by 1-based serials: The ID is one more than the index in a _sorted_ `Array` of questions.
 * Read from `DASIQuestions.json`
 * The list is an immutable global: DASIQuestion.questions.
 * THIS IS AN ARRAY, zero-indexed, and it is public.
 * For DASI numbering, refer to the `DASIQuestion.id`. There are also min and max `presenting` values, and a range of valid `presenting`.

 ### struct DASIUserResponse

 Joins a question (referenced by ID), a response (`AnswerState`) and a time stamp representing which questionj was answered, how, and when  for a **single question**,  It knows how to order itself, and convert itself to a comma-separated string for use in assembling full rows in the output CSV file.

### struct DASIResponseList

An `ObservableObject` intended to be the `@EnvironmentObject` for the DASI project. It takes the Subject ID and initializes its `[DASIUserResponse]` array of `answers`.
 - -Warning: `@Environmentobject` does not work in this use.

 It serves as the façade for the user's responses to the questions.

 * `responseForQuestion(id:)` - yelds the answer (yes/no/unknown) for the question under that ID.
 * `didRespondToQuestion(id:with:) `- replaces the `answers` element for that ID with one with a new `AnswerState`.
 * `unknownResponseIDs` - list of IDs for questions that are as yet `unknown`.
 * `resetQuestion(id:)`  - sets the identified response to `unknown`
 * `reset()` - reset all responses to `unknown`.
 * `csvDASIRecords` - scans all responses, prepares the `csv` representation of each, and returns a `String` containing them delimited by CSV newlines (`\r\n`, per Microsoft's specifications.)

The `String` returned by `csvDASIRecords` can be converted to `Data`, and written out to disk.

*/

// MARK: - DASIReportErrors
/// Errors that may arise from converting DASI responses to a CSV file.
/// - warning: Largely unused.
enum DASIReportErrors: Error {
//    case wrongDataType(UTType)
//    case notRegularFile
//    case noReadableReport
//    case missingDASIHeader(String)
//    case wrongNumberOfResponseElements(Int, Int)
//    case outputHandleNotInitialized

    case couldntCreateDASIFile
}

// MARK: - DASIResponseList
/// Responses to all DASI questions. Records changes to each response. Encodes the response list into the data for a CSV file. This is the data model _only,_ without regard for how it is to be stored.
///
/// Observable.
final class DASIResponseList: ObservableObject, CSVRepresentable {
    /* private(set) */ var answers: [DASIUserResponse]

    /// Create `DASIResponses, filling all items in with `.unlnown`.
    init() {
        self.answers   = DASIQuestion
            .questions
            .map { DASIUserResponse(id: $0.id, response: .unknown) }
    }

    // MARK: Responses
    /// Index of the first (only, we hope) element of `answers` that matches a given ID.
    /// - Parameter id: The `id` (one-based, not necessarily ordered) to search for
    /// - Returns: The index into the `answers` array, or `nil` if no answer by that `id` exists.
    private func answerIndex(forID id: Int) -> Int? {
        guard let retval = answers.firstIndex(
            where: { response in response.id == id })
        else { return nil }
        return retval
    }

    /// The user's response to a question.
    ///
    /// Think of this as the inverse of `didRespondToQuestion(id:with:)`
    /// - Parameter id: The `id` (one-based, not necessarily ordered) to search for
    /// - Returns: The `AnswerState` for that question, `.yes`, `.no`, or `.unknown`; or `nil` if no answer with that `id` was found.
    /// - note: If `id` is not present, the return value is `.unk
    func responseForQuestion(identifier: Int) -> AnswerState? {
        guard let responseIndex = answerIndex(forID: identifier) else { return nil }
        let theAnswer = answers[responseIndex]
        return theAnswer.response
    }

    /// Record the user's response to a  question.
    ///
    /// Think of this as the inverse of `responseForQuestion(id:)`
    /// - Parameters:
    ///   - questionID: The **`id`** of the `DASIUserResponse` being answered. The method will find the matching array index.
    ///   - state: The user's response.
    func didRespondToQuestion(
        id questionID: Int,
        with state: AnswerState) {
            guard let replacementIndex = answerIndex(forID: questionID)
            else { preconditionFailure("incoming questionID \(questionID) is out of range.")}
            answers[replacementIndex] = answers[replacementIndex].withResponse(state)
            // Timestamp updates in withResponse(_:)
        }


    // MARK: CSV formatting

    /// Generate a single-line comma-delimited report of `SubjectID`, `timestamp`, and number/answer pairs.
    var csvLine: String {
        let completedAnswers = answers.filter { $0.response != .unknown }
        precondition(completedAnswers.count == answers.count,
        "Got here with missing answers")
        let arrayOfAnswers = answers.map(\.csvLine)
        if !SubjectID.isSet { SubjectID.id = "SAMPLE" }
        return "\(SeriesTag.dasi.rawValue),\(SubjectID.id)," + arrayOfAnswers.csvLine
    }
}

// MARK: - Handling missing answers
extension DASIResponseList {
    /// The `DASIQuestion` `id`s of all responses that are still `.unknown`
    /// - note: The survey is not resdy to commit before this array is empty.
    var unknownResponseIDs: [Int] {
        return answers
            .filter { $0.response == .unknown }
            .map(\.id)
            .sorted()
    }

    var firstUnasweredQuestion: Int? {
        guard let id = unknownResponseIDs.first else {
            return nil
        }
        return id
    }

    var formatUnansweredIDs: String? {
        return unknownResponseIDs.colloquially
    }

    /// Whether the DASI report is complete, there being no `unknown` responses
    var isReadyToPublish: Bool { self.unknownResponseIDs.isEmpty }

}

/*
 PROBLEM:
    DASIResponseList.csvLine preconditions that none of the questions are unanswered.
 This is known in DRL, but it's not a view.
 The cheapest way out of this is for the final card of the DASI container to put up an alert identifying the gaps and refusing to proceed.
 Approach?
 ASSUMING the final, goodbye view can be decorated independantly,
 check the DRL for isReadyToPublish. If not,
    compose the message and trigger the alert, advising of the missing answers.
    Bonus: The CTA button brings you to the first unanswered question.
 */

