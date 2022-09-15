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
enum DASIReportErrors: Error {
    case wrongDataType(UTType)
    case notRegularFile
    case noReadableReport
    case missingDASIHeader(String)
    case wrongNumberOfResponseElements(Int, Int)
    case outputHandleNotInitialized
    case couldntCreateDASIFile
}

// MARK: - DASIResponseList
/// Responses to all DASI questions. Records changes to each response. Encodes the response list into the data for a CSV file. This is the data model _only,_ without regard for how it is to be stored.
///
/// Observable.
final class DASIResponseList: ObservableObject {
    @EnvironmentObject var subjectIDObject: SubjectID

    public private(set) var answers: [DASIUserResponse]

    /// Create `DASIResponses`
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

    /// Census of the `DASIUserResponse`s in the `answers` array that match the indicated response type.
    /// - Parameter kind: The `AnswerState` of interest.
    /// - Returns: A `Set` of the `answers` that match the reply type
    func responses(of kind: AnswerState) -> Set<DASIUserResponse> {
        let desired = answers
            .filter { $0.response == kind }
        return Set(desired)
    }

    /// The `DASIQuestion` `id`s of all responses that are still `.unknown`
    /// - note: The survey is not resdy to commit before this array is empty.
    var unknownResponseIDs: [Int] {
       return answers
            .filter { $0.response == .unknown }
            .map(\.id)
            .sorted()
    }

    /// Whether the DASI report is complete, there being no `unknown` responses
    var isReadyToPublish: Bool { self.unknownResponseIDs.isEmpty }

    /// Set the response to one question, identified by (1-based) `id` to `.unknown`.
    /// - Parameter id: The question to withdraw.
    func resetQuestion(id: Int) {
        guard let answerIndex = answerIndex(forID: id) else {
            assertionFailure("\(#function) - out-of-bounds answer ID \(id)")
            return
        }
        let newValue = answers[answerIndex]
            .withResponse(.unknown)
        answers[answerIndex] = newValue
    }

    /// Set all responses to `.unknown`
    func clearResponses() {
        let result = answers.map {
            $0.withResponse(.unknown)
            // Timestamp updates in init()
        }
        self.answers = result
    }

    /*
    /// Set all responses in the `shared` `DASIResponseList` to .unknown. This is data _only,_ without regard for storage (e.g. the report file.
    static func clearResponses() {
        BSTAppStageState.shared.dasiResponses.clearResponses()
    }

    static func clearAllDASI() async throws {
        clearResponses()
        try await BSTAppStageState.shared.dasiFile?.clearReportFile()
    }
     */
    func teardownFromSubjectID() async throws -> DASIResponseList? {
        clearResponses()
        return self
    }

    // MARK: CSV formatting

    /// Generate a single-line comma-delimited report of `subjectID`, `timestamp`, and number/answer pairs.
    var csvLine: String? {
//        guard let subjectID = subjectIDObject.subjectID else {
//            assertionFailure("No subject ID, shouldn't get to \(#function) in the first place.")
//            return nil
//        }
        let okayResponseValues: Set<AnswerState> = [.no, .yes]
        let usableResponses = answers
            .filter {
                okayResponseValues.contains($0.response)
            }
        // TODO: Consider whether < answers.count is an error.
        guard let firstUsable = usableResponses.first
        else { return nil }

        let firstTimestamp = firstUsable.timestamp.iso

        let numberedResponses = usableResponses
            .sorted(by: { $0.id < $1.id })
            .map {
                String(describing: $0.id)
                + ","
                + String(describing: $0.response)
            }

        let components: [String] =
        [subjectIDObject.subjectID] + [firstTimestamp] + numberedResponses

        assert(components.count == 2+DASIQuestion.count,
               "Expected \(2+DASIQuestion.count) response items, got \(components.count)")

        return components.joined(separator: ",")
    }
}
