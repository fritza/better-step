//
//  SurveyReportFile.swift
//  Async Accel
//
//  Created by Fritz Anderson on 4/5/22.
//

import Foundation

final class SurveyReportFile {
    // TODO: DASIReportFile was SubjectIDDependent.

    // MARK: - Properties
    let dasiFileBaseName: String
    /// The directory into which the file is to be written.
    let destinationDirectory: URL
    var hasWritten = false
    private var responses: [DASIUserResponse] = []

    init(baseName: String,
         directory: URL) {
        dasiFileBaseName = baseName
        destinationDirectory = directory
        responses = [DASIUserResponse]()
    }

    // MARK: - User responses
    /// Append a single `DASIUserResponse` to the report
    /// - Parameter response: The user's response to a DASI question.
    func add(response: DASIUserResponse) {
        responses.append(response)
    }

    /// Append zero or more `DASIUserResponse`s to the report.
    /// - Parameter userResponses: An `Array` of `DASIUserResponse` to append.
    func add(responses userResponses: [DASIUserResponse]) {
        responses.append(contentsOf: responses)
    }

    /// Append all the `DASIUserResponse`s from the accumulated `DASIResponseList`
    /// - Parameter userResponses: The `DASIResponseList` object that received the user's live responses to the DASI questions.
    func set(responses userResponses: DASIResponseList) async {
        self.responses =
        await MainActor.run {
            userResponses.answers
        }
    }

    // MARK: - File operations
    private var outputHandle: FileHandle?

    /// The `URL` for the output file.
    var destinationURL: URL {
        let destination = destinationDirectory
            .appendingPathComponent("\(dasiFileBaseName).csv")
        return destination
    }

    /// Delete the destination file.
    ///
    /// **Do not** use this in the class life cycle. The file is supposed
    /// to survive after it has been built.
    private func removeFile() throws {
        try FileManager.default
            .deleteIfPresent(destinationURL)
    }

    /// Create and open the report file for writing, deleting any existing DASI file for this subject.
    /// - throws: An error if the file does not exist. This ought to be fatal.
    private func createAndOpenHandle() throws {
        let fm = FileManager.default
        try fm.deleteAndCreate(at: destinationURL)
        outputHandle = try FileHandle(
            forWritingTo: destinationURL)
    }

    // MARK: - File content
    /// Process the `responses` list into lines of `csv` data for each, and then into `Data`
    ///
    /// The returned `Data` may be empty if `self` contains no `DASIUserResponses` (plausible), or the `String`-to-UTF-8 data conversion failed (should be impossible).
    /// - warning: Do not use `compose()` before all desired records have been entered in `responses`. There is no provision for resuming a partial write.
    /// - Returns: `Data` with content for the `csv` file. May be empty.
    private func compose() -> Data {
        let content = responses
            .flatMap(\.csvStrings)
            .joined(separator: "\r\n")
        return content.data(using: .utf8)
        ?? Data()
    }

    /// Translates the accumulated `DASIUserResponse`s into `csv` format and writes it to the designated file.
    ///
    /// Regardless of success, expect the file to be closed and the `outputHandle` file handle to be nilled-out.
    /// - throws: `DASIReportErrors.couldntCreateDASIFile` if `createOutputFile` failed. Errors arising from the use of the write-only `FileHandle` for the output file.
    func writeAndClose() throws {
        let csvData = compose()
        let handle = try FileManager.default.deleteCreateAndOpen(destinationURL)
        outputHandle = handle
        try handle.write(contentsOf: csvData)
    }
}

