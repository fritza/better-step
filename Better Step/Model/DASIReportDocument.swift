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
        case missingDASIHeader(String)
        case wrongNumberOfResponseElements(Int, Int)
    }

    static var readableContentTypes = [UTType.commaSeparatedText]
    @Published var report: DASIReport

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try report.writeToCSVData()
        let retval = FileWrapper(regularFileWithContents: data)
        return retval
    }

    func fileWrapper(snapshot: Snapshot, configuration: WriteConfiguration) throws -> FileWrapper {
        return try fileWrapper(configuration: configuration)
    }

    func snapshot(contentType: UTType) throws -> Snapshot {
        return report
    }

    init() {
        report = DASIReport()
    }

    /// `ReferenceFileDocument` conformance. yield `DASIReport` from the file from the configuration.
    /// - Parameter configuration: `FileDocumentReadConfiguration` received from the OS designating the data file to read.
    /// - throws: `Errors.wrongDataType` upon wrong file type, non-regular file, not readable, errors from the `DASIReport`initializer.
    init(configuration: FileDocumentReadConfiguration) throws {
        let (fileType, wrapper) = (configuration.contentType, configuration.file)
        guard Self.readableContentTypes.contains(fileType),
              wrapper.isRegularFile,

              let data = wrapper.regularFileContents else {
                  throw Errors.wrongDataType(fileType)
              }
        report = try DASIReport(data: data)
    }
}

