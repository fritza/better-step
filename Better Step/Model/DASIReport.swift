//
//  DASIReport.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/17/22.
//

import Foundation

// MARK: - DASIReport
/// A collection of `DASIResponses` and the capacity to format and write them into a report file (implicitly `.csv`).
///
/// Distinguished from `DASIResponses`, which also keeps an array of user-response values, but is not concerned with output.
///
/// You prepare a DASI report file by creating a `DASIReport` actor with the base name of the report file and its destination directory. Use `add(response:)`, `add(responses:)` or `set(responses:)` to fill the contents of the file.
///
/// Call `writeAndClose()` to create and fill the output file.
/// - warning: Records may be added piecemeal, but appending to the output file is not supported. `writeAndClose()` will rewrite ths entire file from the start.
actor DASIReport {
    /// The base name (no extension, no path) of the output file.
    let dasiFileBaseName: String
    /// The directory into which the file is to be written.
    let destinationDirectory: URL
    var hasWritten = false

    init(baseName: String,
         directory: URL) {
        dasiFileBaseName = baseName
        destinationDirectory = directory
        responses = [DASIUserResponse]()
    }

    /// Empty this `DASIReport`'s record of responses.
    ///
    /// This isn't static, worse luck, so the caller must either retain the instance after use, or _maybe_ create a new one with the same name and directory.
    public func clear() throws {
        let fm = FileManager.default
        try fm.deleteIfPresent(destinationURL)
        // NOTE: Not sure what happens if destinationURL somehow refers to a directory
        responses = []
        try outputHandle?.close()
        outputHandle = nil
    }

    // MARK: - Adding response items
    private var responses: [DASIUserResponse] = []

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

    /// Append all the `DASIUserResponse`s from the accumulated `DASIResponses`
    /// - Parameter userResponses: The `DASIResponses` object that received the user's live responses to the DASI questions.
    func set(responses userResponses: DASIResponses) {
        self.responses = userResponses.answers
    }

    // MARK: - File operations

    /// The `URL` for the output file.
    var destinationURL: URL {
        // FIXME: Make into a lazy property.
        let destination = destinationDirectory
            .appendingPathComponent("\(dasiFileBaseName).csv")
        return destination
    }

    /// Delete the destination file.
    ///
    /// **Do not** use this in the class life cycle. The file is supposed
    /// to survive after it has been built.
    private func remove() throws {
        try FileManager.default
            .deleteIfPresent(destinationURL)
    }

    /// Create an empty output file at `destinationURL`, deleting any existing item.
    /// - throws: `DASIReportErrors.couldntCreateDASIFile` if the remove or creation failed.
    private func createOutputFile() throws {
        // FIXME: Use FileManager.deleteAndCreate(at:)
        // TODO:  merge with prepareHandle into deleteCreateAndOpen(_:).
        let fm = FileManager.default
        if fm.fileExists(atURL: destinationURL) {
            // NOTE: Not sure what happens if destinationURL somehow refers to a directory
            try fm.removeItem(at: destinationURL)
        }
        let success = fm.createFile(
            atPath: destinationURL.path,
            contents: nil)
        if !success { throw DASIReportErrors.couldntCreateDASIFile }
    }

    private var outputHandle: FileHandle?

    /// Create and open the report file for writing.
    /// - throws: An error if the file does not exist. This ought to be fatal.
    private func prepareHandle() throws {
        // TODO:  merge with createOutputFile into deleteCreateAndOpen(_:).
        outputHandle = try FileHandle(
            forWritingTo: destinationURL)
    }

    /// Write `Data` through the `outputHandle`.
    ///
    /// While `performWrite(_:)` could append to the file, the rest of `DASIReport` does not support composition among partial lists.
    /// - throws: Whatever might come of `FileHandle.write(contentsOf:)`
    /// - Parameter contentData: The `Data` to write.
    private func writeThroughHandle(_ contentData: Data) throws {
        precondition(outputHandle != nil,
        "Attempt to write to \(dasiFileBaseName).csv before opening it.")
        try outputHandle!.write(contentsOf: contentData)
    }

    @available(*, deprecated,
                message: "Do not close the file automatically.")
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
        defer {
            try! outputHandle?.close()
            outputHandle = nil
        }

        // TODO: Consider consolidating
        //       to FileManager.deleteCreateAndOpen
        try createOutputFile()
        try prepareHandle()

        let csvData = compose()
        try writeThroughHandle(csvData)
    }
}

