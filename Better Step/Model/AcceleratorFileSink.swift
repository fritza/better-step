//
//  AcceleratorFileSink.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/24/22.
//

import Foundation
import Collections

/// A pipeline between a stream of `AccelerometerItem`s and the `csv` file to be written from them.
///
/// - warning: When the `subjectID` changes, client code is responsible for generating a new `AccelerometerFileSink`.  I don't see a way to do it that's `Sendable`.
final actor AccelerometerFileSink {
    // No @EnvironmentObjects in actors.
    static let dequeInitialSize     = 1000
    var subjectID               : String
    let fileURL                 : URL
    private(set) var writeHandle: FileHandle?
    var acceleratorQueue        : Deque<AccelerometerItem>

    /// Create an `AccelerometerFileSink` bridging between a stream of `AcceleratorItem`s and `csv` output.
    ///
    /// The global subjectID (`SubjectID.shared`) is captured upon initialization, and _never_ updated.
    /// - parameters:
    ///     - subject: The ID of the subject/run.
    /// - returns: `nil` if either the destination (per-subject) directory or the walking `csv` file could not be created.
    init() async throws
    {
        assert(SubjectID.shared.subjectID != nil,
               "\(#function): SubjectID.shared not initialized (shouldn't get here before it's valid.")
        self.subjectID = SubjectID.shared.subjectID!

        var _queue = Deque<AccelerometerItem>()
        _queue.reserveCapacity(Self.dequeInitialSize)
        acceleratorQueue = _queue

        // Apparently fileURLForSubject... is isolated to @MainActor.
        let _fileURL =
        try await PerSubjectFileCoordinator.shared
            .fileURLForSubject(
                purpose: .walkingReportFile,
                creating: true)
        fileURL = _fileURL
        let _writeHandle = try FileHandle(
            forWritingTo: _fileURL)
        writeHandle = _writeHandle
    }

    func close() throws {
        // (Had warned that the AsyncStream should close,
        // but the actor isn't responsible for the
        // device-reading part.
        try flushToFile()
        try writeHandle?.close()
        writeHandle = nil
    }

    func clear() throws {
        // Doesn't flush the contents.
        try writeHandle?.close()
        try FileManager.default.deleteIfPresent(fileURL)
        acceleratorQueue.removeAll()
    }

    // FIXME: Must this be async?
    func append(record: AccelerometerItem) {
        Task {
            acceleratorQueue.append(record)
            try flushToFile()
        }
    }

    // FIXME: Must this be async?
    func append(records: [AccelerometerItem]) throws {
        Task {
            acceleratorQueue.append(contentsOf: records)
            try flushToFile()
        }
    }

    private func flushToFile() throws
    {
        let queueContents = Array(acceleratorQueue)
        acceleratorQueue.removeAll()

        let csvs = queueContents
            .map(\.csv)
            .joined(separator: "\r\n")
            .appending("\r\n")
        // The newline is a terminator, not a separator.
        // The file should(?) end with a blank line.
        // joined(separator:) doesn't put the empty
        // line at the end. Therefore append it.

        let csvData = csvs.data(using: .utf8)!
        try writeHandle?.write(contentsOf: csvData)
    }
}


