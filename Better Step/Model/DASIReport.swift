//
//  DASIReport.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/10/22.
//

import Foundation
import Combine
import SwiftUI
import UniformTypeIdentifiers
import CodableCSV

/*
 What I want to know:
 I don't have the user ID immediately upon opening
 But I need to access the document based on the user ID.
 */

// A DASI report is an array of all DASI responses, verify it'e all IDs, all consecutive.
// MARK: - DASIReport
final class DASIReport: ObservableObject, Codable {
    var subjectID: String?
    public private(set) var timestamp: Date
    public private(set) var answers: [DASIResponse]

    init(data: Data) throws {
        let reader = try CSVReader(input: data) { configuration in
            configuration.delimiters = (field: ",", row: "\r\n")
            configuration.headerStrategy = .firstLine
        }
        // Assuming the first line is a header and I have to discard it.
        var answerList: [DASIResponse] = []
        while let record = try reader.readRecord() {
            guard let numberField = record["Number"],
                  let recordNumber = Int(numberField) else {
                      throw DASIReportDocument.Errors.missingDASIHeader("Number")
                  }
            guard let responseField = record["Response"],
                  let response = AnswerState(described: responseField) else {
                      throw DASIReportDocument.Errors.missingDASIHeader("Response")
                  }
            let element = DASIResponse(id: recordNumber, response: response)
            answerList.append(element)
        }
        precondition(answerList.count == 12,
                     "Expected the doc file to have 12 answers, has \(answerList.count)")

        self.answers = answerList
        // TODO: What to do with the timestamp?
        // The survey doesn't really need it.
        // SUGGESTION: Bootleg a line in the report for subject ID and ISO-8601
        self.timestamp = Date()
    }

    init(forSubject subjectID: String? = nil) {
        self.subjectID = subjectID
        timestamp = Date()
        answers = DASIResponse.emptyResponses
    }

    var score: Double {
        guard !answers.isEmpty else { return 0.0 }
        let retval = answers.reduce(0.0) { sum, response in
            return sum + response.score
        }
        return retval
    }

    func responseForQuestion(id: Int) -> AnswerState {
        guard let theResponse = answers.first(where: {
            // Question ID starts from 1
            $0.id == id }) else {
            return .unknown
        }
        return theResponse.response
    }

    func didRespondToQuestion(id questionID: Int,
                           with state: AnswerState) {
        let newResponse = DASIResponse(id: questionID,
                                       response: state)
        answers.removeAll { $0 == newResponse }
        answers.append(newResponse)
        // TODO: Should not be necessary:
        answers.sort()
        timestamp = Date()
    }

    func resetQuestion(id questionID: Int) {
        answers.removeAll { $0.id == questionID }
    }

    func reset() { answers.removeAll() }
}

// MARK: - CSV
extension DASIReport {
    /// Generate a `Data` containing the CSV encoding of this report.
    ///
    /// Uses the `CodableCSV` package to be found on GitHub. The data set is too small to consider `CSVEncoder`.
    /// - Returns: `Data`, the CSV encoding of `self`.
    /// - throws: There are 4 `try` points in the function, all thrown in the creation or use of `CSVWriter`.
    func writeToCSVData() throws -> Data {
        let writer = try CSVWriter() { config in
            config.headers    = ["Number", "Response"]
            config.delimiters = (field: ",", row: "\r\n")
        }
        for element in answers {
            try writer.write( row: element.csvStrings )
        }
        try writer.endEncoding()
        let retval = try writer.data()

        #if DEBUG
        let verification = String(data: retval, encoding: .utf8)
        print(verification ?? "\(#function): can’t recover a String from output)")
        #endif

        return retval
    }

    func writeTo(url: URL) throws {
        // Doesn't this need something that will collect
        //
    }
}
