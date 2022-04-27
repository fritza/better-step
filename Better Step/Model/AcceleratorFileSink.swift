//
//  AcceleratorFileSink.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/24/22.
//

import Foundation
import Collections
// TODO: Should this be a category in a separate file?
import Combine

/// A pipeline between a stream of `AccelerometerItem`s and the `csv` file to be written from them.
///
/// - warning: When the `subjectID` changes, client code is responsible for generating a new `AccelerometerFileSink`.  I don't see a way to do it that's `Sendable`.
final actor AccelerometerFileSink {
    enum Errors: Error {
        case noHandleOpen(String?)

        var localizedDescription: String {
            switch self {
            case .noHandleOpen(let fileName):
                return "attempt to write a CSV file (\(fileName ?? "untitled")) that isn't open."
            }
        }
    }

    static let dequeInitialSize = 1000
    var fileURL                 : URL!
    private(set) var writeHandle: FileHandle?
    var acceleratorQueue        : Deque<AccelerometerItem>

    static var shared: AccelerometerFileSink?
    // Okay, so how do you fill it?
    // There's a race between the asynchronous init
    // and the first use.
    // SubjectID: init addresses .shared. Does anyone else beforehand? Is that a problem, given that the access here is ostensibly a read, though it might have a side effect.

    /// Create an `AccelerometerFileSink` bridging between a stream of `AcceleratorItem`s and `csv` output.
    ///
    /// The `SubjectID` environment value is captured upon initialization, and _never_ updated.
    /// - returns: `nil` if either the destination (per-subject) directory or the walking `csv` file could not be created.
    init() async throws
    {
        var _queue = Deque<AccelerometerItem>()
        _queue.reserveCapacity(Self.dequeInitialSize)
        acceleratorQueue = _queue
        // Apparently fileURLForSubject... is isolated to @MainActor.
        try open()
    }

    /// Open a `FileHandle` for writing to an acceleration CSV file.
    ///
    /// `self.fileURL` is refreshed whenever a CSV is opened for writing: The URL depends on the current subject ID.
    /// - throws: `FileHandle` error, probably upon `fileURL` not referring to an extant file.
    func open() throws {
        guard let fc = PerSubjectFileCoordinator.shared else {
            fatalError("file coordinator not set")
        }
        fileURL = try fc
            .fileURLForSubject(
                purpose: .walkingReportFile,
                creating: true)
        let _writeHandle = try FileHandle(
            forWritingTo: fileURL)
        writeHandle = _writeHandle
    }

    /// Storage for the subject-id `.sink`. No need to purge the set, as accelerometry file handling lasts for the life of the app.
    var cancellables: Set<AnyCancellable> = []

    /// The `Task` of closing out and creating per-user CSV files.
    ///
    /// Clients should watch for success/failure before assuming the output file is ready..
    var updateSubjectTask: Task<Void, Error>?
    /// Watch the shared `SubjectID`. Flush, close, and open the respective CSV files.
    ///
    /// No immediate error (it just enqueues); any resulting errors go through `.updateSubjectTask`.
    func observeSubjectID() {
        SubjectID.shared.$subjectID
            .removeDuplicates()
            .sink {
                newID in
                self.updateSubjectTask = Task {
                    // Any changed ID closes the active
                    // file (writeHandle != nil)
                    // If non-nil, it opens a new one.

                    // Tear down the current file
                    if self.writeHandle != nil {
                        try self.close()
                    }

                    // If cancelled, don't open, and
                    // pinch off the writeHandle,
                    // ATW nobody wants to.
                    if Task.isCancelled {
                        // ATW nobody wants to cancel this Task.
                        // If cancelled, don't open,
                        // pinch off the writeHandle,
                        // no current SubjectID.
                        self.writeHandle = nil
                        return
                    }

                    // The ID is ready for a new file.
                    try self.open()
                    return
                }
            }
            .store(in: &cancellables)
    }

    /// Write any unsaved records to the file, close it, and `nil`-out the old `FileHandle`.
    /// - throws: No file open, can't write to flush-out pending data.
    func close() throws {
        guard let handle = writeHandle else {
            throw Errors.noHandleOpen(fileURL.lastPathComponent)
        }
        try flushToFile()
        try handle.close()
        writeHandle = nil
    }

    /// Immediately delete the output file. Don't bother flushing-out the pending records.
    /// - throws: Attempt to clear a file not open, can't close the handle, can't delete the file (Shouldn't Happen).
    func clear() throws {
        // Doesn't flush the contents.
        guard let handle = writeHandle else {
            throw Errors.noHandleOpen(fileURL.lastPathComponent)
        }
        try handle.close()
        try FileManager.default.deleteIfPresent(fileURL)
        acceleratorQueue.removeAll()
    }

    // FIXME: Must this be async?
    /// Append the record item to the output queue and then flush the queue out to storage.
    ///
    /// **See** `flushToFile()`
    /// - parameter record: The `AccelerometerItem` to append.
    func append(record: AccelerometerItem) {
        Task {
            acceleratorQueue.append(record)
            try flushToFile()
        }
    }

    // FIXME: Must this be async?
    /// Append an `Array` of record items to the output queue and then flush the queue out to storage. The append is batched, not iterated through `append(record:)`
    ///
    /// **See** `flushToFile()`
    /// - parameter records: The `AccelerometerItem`s to append.
    func append(records: [AccelerometerItem]) throws {
        Task {
            acceleratorQueue.append(contentsOf: records)
            try flushToFile()
        }
    }

    /// Append the enqueued accelerometer records to the output file.
    /// - warning: This does _not_ call `FileManager.synchronize`.
    private func flushToFile() throws
    {
        guard let handle = writeHandle else {
            throw Errors.noHandleOpen(fileURL.lastPathComponent)
        }
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
        try handle.write(contentsOf: csvData)
    }
}


