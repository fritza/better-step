//
//  DASIReportContents.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/24/22.
//

import Foundation
import Combine
import UniformTypeIdentifiers

/*
 # Theory behind DASI reporting.

 # Primitive data structures

 * Questions as such: Text, ID, and scoring.
    * struct `DASIQuestion`
    * The literature identifies questions by 1-based serials, meaning the ID is one more than the index in an array of questions.
    * Read from `DASIQuestions.json`
    * The list is an immutable global: DASIQuestion.questions.
    * THIS IS AN ARRAY, zero-indexed, and it is public.
    * TO DO: hide .questions and expose a subscript by QuestionID. static with(id:) should be a subscript.
    * TO DO: Remove the "identifier" property, which is in the .plist data, and a codable part of the struct.

    * Indexed by QuestionID:

 WHAT IS DASIReport, and why is it no longer in the build order?
 */

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

// TODO: answers should never be empty.
//       if you need to empty it,
//       repopulate it with unresponded

final class DASIReportContents: ObservableObject {
    // TODO: Make a collection
    var subjectID: String?
//    public private(set) var timestamp: Date
    public private(set) var answers: [DASIResponse]

    init(forSubject subjectID: String? = nil) {
        self.subjectID = subjectID
//        self.timestamp = Date()
        self.answers   = DASIQuestion
            .questions
            .map { DASIResponse(id: $0.id, response: .unknown) }
    }

    func responseForQuestion(id: QuestionID) -> AnswerState {
        precondition(id.isValid)

        guard let theResponse = answers.first(where: {
            // Question ID starts from 1
            $0.id == id }) else {
                return .unknown
            }
        return theResponse.response
    }

    func didRespondToQuestion(
        id questionID: QuestionID,
        with state: AnswerState) {
            answers[questionID.index]
            = answers[questionID.index]
                .withResponse(state)
        }

    var emptyResponseIDs: [QuestionID] {
       return answers
            .filter { $0.response == .unknown }
            .map(\.id)
    }

    func resetQuestion(questionID: QuestionID) {
        let newValue = answers[questionID.index]
            .withResponse(.unknown)
        answers[questionID.index] = newValue
    }

    func reset() {
        let result = answers.map {
            $0.withResponse(.unknown)
        }
        self.answers = result
    }

    var CSVDASIRecords: String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = .withInternetDateTime

        let prefix = [subjectID ?? "n/a", isoFormatter.string(from: Date())
                      ]
        let eachLine = answers
            .flatMap {
                prefix + $0.csvStrings
            }
        let allLines = eachLine
            .joined(separator: ",")
        return allLines
    }
}
