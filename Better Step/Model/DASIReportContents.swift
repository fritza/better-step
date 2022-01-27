//
//  DASIReportContents.swift
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
 * TO DO: hide .questions and expose a subscript by QuestionID. static with(id:) should be a subscript.
 * TO DO: Remove the "identifier" property, which is in the .plist data, and a codable part of the struct.

 ### struct DASIResponse

 Joins a question (referenced by ID), a response (`AnswerState`) and a time stamp representing which questionj was answered, how, and when  for a **single question**,  It knows how to order itself, and convert itself to a comma-separated string for use in assembling full rows in the output CSV file.

### struct DASIReportContents

An `ObservableObject` intended to be the environmentObject for the DASI project. It takes the Subject ID and initializes its `[DASIResponse]` array of `answers`.

 It serves as the façade for the user's responses to the questions.

 * `responseForQuestion(id:)` - yelds the answer (yes/no/unknown) for the question under that ID.
 * `didRespondToQuestion(id:with:) `- replaces the `answers` element for that ID with one with a new `AnswerState`.
 * `emptyResponseIDs` - list of IDs for questions that are as yet `unknown`.
 * `resetQuestion(id:)`  - sets the identified response to `unknown`
 * `reset()` - reset all responses to `unknown`.
 * `csvDASIRecords` - scans all responses, prepares the `csv` representation of each, and returns a `String` containing them delimited by CSV newlines (`\r\n`, per Microsoft's specifications.)

The `String` returned by `csvDASIRecords` can be converted to `Data`, and written out to disk.


 ### QuestionID
 This insulates the 1-based IDs from the 0-based `Array` induces.

 * RawRepresentable
 * Codable
 * Hashable
 * Strideable
 * CustomStringConvertible

 **Using `QuestionID**

 These types use `QuestionID` to refer to questions and responses.

 * `DASIQuestion`
 * `DASIResponse`
 * `DASIReportContents`

 * `DASIQuestionView`
 * `SurveyView`

 * `QuestionIDTests`

 ## Obsolete — removed
 
 * `DASIReport`
 * `DASIReportDocument
*/

// MARK: - DASIReportErrors
enum DASIReportErrors: Error {
    case wrongDataType(UTType)
    case notRegularFile
    case noReadableReport
    case missingDASIHeader(String)
    case wrongNumberOfResponseElements(Int, Int)
}


/*
 Deleted DASIReport.swift and DASIReportDocument.swift.

 Moved coding notes and DASIReportErrors to DASIReportContents.swift
 */

// MARK: - DASIReportContents
final class DASIReportContents: ObservableObject {
   @AppStorage(AppStorageKeys.subjectID.rawValue) var subjectID: String = ""

    public private(set) var answers: [DASIResponse]

    /// Create `DASIReportContents`
    init() {
        self.answers   = DASIQuestion
            .questions
            .map { DASIResponse(id: $0.id, response: .unknown) }
    }

    // MARK: Responses
    /// The user's response to a question.
    ///
    /// Think of this as the inverse of `didRespondToQuestion(id:with:)`
    /// - Parameter id: The `QuestionID` identifiying the response of concern.
    /// - Returns: The `AnswerState` for that question, `.yes`, `.no`, or `.unknown`.
    func responseForQuestion(id: QuestionID) -> AnswerState {
        precondition(id.isValid)

        guard let theResponse = answers.first(where: {
            // Question ID starts from 1
            $0.id == id }) else {
                return .unknown
            }
        return theResponse.response
    }

    /// Record the user's response to a  question.
    ///
    /// Think of this as the inverse of `responseForQuestion(id:)`
    /// - Parameters:
    ///   - questionID: The ID of the `DASIResponse` being answered.
    ///   - state: The user's response.
    func didRespondToQuestion(
        id questionID: QuestionID,
        with state: AnswerState) {
            answers[questionID.index]
            = answers[questionID.index]
                .withResponse(state)
            // Timestamp updates in withResponse(_:)
        }

    /// The `QuestionID`s of all responses that are still `.unknown`
    /// - note: The survey is not resdy to commit before this array is empty.
    var emptyResponseIDs: [QuestionID] {
       return answers
            .filter { $0.response == .unknown }
            .map(\.id)
    }

    /// Whether the DASI report is complete, there being no `unknown` responses
    var isReadyToPublish: Bool { self.emptyResponseIDs.isEmpty }

    /// Set the response to one question to `.unknown`.
    /// - Parameter id: The question to withdraw.
    func resetQuestion(id: QuestionID) {
        let newValue = answers[id.index]
            .withResponse(.unknown)
        // Timestamp updates in init()
        answers[id.index] = newValue
    }

    /// Set all responses to `.unknown`
    func reset() {
        let result = answers.map {
            $0.withResponse(.unknown)
            // Timestamp updates in init()
        }
        self.answers = result
    }

    // MARK: CSV formatting
    /// All DASI responses formatted into multiple lines of `csv`.
    ///
    /// The line delimiter, per Microsoft spec, is "`\r\n`".
    public var csvDASIRecords: String {
        let prefix = [subjectID]
        // per-response array of arrays of response fields
        let allLines = answers
            .map { (record: DASIResponse) -> String in
                let recordStrings = record.csvStrings
                let retval = (prefix + recordStrings)
                    .joined(separator: ",")
                return retval
            }
            .joined(separator: "\r\n")
        return allLines
    }

    /// All DASI responses, in `.csv` format, encoded into `Data`.
    /// - throws: `fatalError` if the `string`-to-`Data` reduction fails.
    public var csvData: Data {
        guard let retval = csvDASIRecords
                .data(using: .utf8) else {
                    fatalError()
                }
        return retval
    }
}
