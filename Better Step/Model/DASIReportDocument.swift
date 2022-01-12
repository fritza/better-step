//
//  DASIReportDocument.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/12/22.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import CodableCSV

// MARK: - DASIReportDocument
final class DASIReportDocument: ReferenceFileDocument, ObservableObject
//, Codable
{
    typealias Snapshot = DASIReport



    enum Errors: Error {
        case wrongDataType(UTType)
        case notRegularFile
        case noReadableReport
    }

    static var readableContentTypes = [UTType.commaSeparatedText]
    @Published var report: DASIReport

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try report.writeToCSVData()
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

