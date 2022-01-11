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

/*
 What I want to know:
 I don't have the user ID immediately upon opening
 But I need to access the document based on the user ID.
 */

final class DASIReportDocument: ReferenceFileDocument, ObservableObject
//, Codable
{
    typealias Snapshot = DASIReport



    enum Errors: Error {
        case wrongDataType(UTType)
        case notRegularFile
        case noReadableReport
    }

    static var readableContentTypes: [UTType] = [.data]
    @Published var report: DASIReport

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(report)
        let retval: FileWrapper =  FileWrapper(regularFileWithContents: data)
        return retval
    }

    func fileWrapper(snapshot: Snapshot, configuration: WriteConfiguration) throws -> FileWrapper {
        return try fileWrapper(configuration: configuration)
    }

    func snapshot(contentType: UTType) throws -> Snapshot {
        return report
    }

    init() {
        report = DASIReport(forSubject: "FOR RENT")
    }

//    snap

    init(configuration: FileDocumentReadConfiguration) throws {
        // Accept content type
        let (fileType, wrapper) = (configuration.contentType, configuration.file)
        guard Self.readableContentTypes.contains(fileType) else {
            throw Errors.wrongDataType(fileType)
        }
        guard wrapper.isRegularFile else {
            report = DASIReport()
            return
        }

        guard let data = wrapper.regularFileContents else {
            throw Errors.noReadableReport
        }

        let retval = try JSONDecoder().decode(DASIReport.self,
                                              from: data)
        report = retval
    }
}

// A DASI report is an array of all DASI responses, verify it'e all IDs, all consecutive.

final class DASIReport: ObservableObject, Codable {
    var subjectID: String?
    public private(set) var timestamp: Date
    public private(set) var answers: [DASIResponse]

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
