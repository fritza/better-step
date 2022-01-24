//
//  AcceleratorFileSink.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/24/22.
//

import Foundation
import Collections

///// URL for a reporting csv file (per subject/run, per purpose.
/////
///// If no file exists at that URL, and if `creating`, create an empty file at that location.
///// - Parameters:
/////   - subject: The ID of the subject/run for whom the files are generated
/////   - purpose: The role (`dasiReportFile`, `walkingReportFile`) the file serves
/////   - creating: `true` if an empty file of that name is to be created, Default is false.
///// - Returns: A URL for the requested file, no matter whether it now exists.
///// - throws: FileManager errors if the directory or file are absent and could not be created.
//func fileURLForSubjectID(
//    _ subject: String,
//    purpose: SubjectFileCoordinator.FlatFiles,
//    creating: Bool = false) throws -> URL {
//        let fm = FileManager.default
//
//    // Where the file for this subject and purpose should be
//        let retval = try fm
//            .directoryURLForSubjectID(
//                subject, creating: true)
//        .appendingPathComponent(purpose.rawValue, isDirectory: false)
//
//    if creating && !fm.fileExists(atURL: retval) {
//        let creationSucceeded = fm
//            .createFile(atPath: retval.path,
//                        contents: nil)
//        guard creationSucceeded else {
//            throw FileStorageErrors.cantCreateFileAt(retval)
//        }
//    }
//    return retval
//}



/// A pipeline between a stream of `AccelerometerItem`s and the `csv` file to be written from them.
final actor AccelerometerFileSink {
    static let dequeInitialSize     = 10_000
    var subjectID: String
    let fileURL: URL
    let writeHandle: FileHandle
    var acceleratorQueue: Deque<AccelerometerItem>

    /// Create an `AccelerometerFileSink` bridging between a stream of `AcceleratorItem`s and `csv` output.
    /// - parameters:
    ///     - subject: The ID of the subject/run.
    /// - returns: `nil` if either the destination (per-subject) directory or the walking `csv` file could not be created.
    init(subject: String) throws
    {
        let fm = FileManager.default
        let _fileURL = try fm
            .fileURLForSubjectID(
                subject,
                purpose: .walkingReportFile,
                creating: true)
        fileURL = _fileURL

        self.subjectID = subject
        var _queue = Deque<AccelerometerItem>()
        _queue.reserveCapacity(Self.dequeInitialSize)
        acceleratorQueue = _queue
        let _writeHandle = try FileHandle(
            forWritingTo: _fileURL)
        writeHandle = _writeHandle
    }

    func close() async throws {
        await flushToFile()
        try writeHandle.close()
    }

    func append(record: AccelerometerItem) async {
        acceleratorQueue.append(record)
        await flushToFile()
    }

    func append(records: [AccelerometerItem]) async {
        acceleratorQueue.append(contentsOf: records)
        await flushToFile()
    }

    func flushToFile() async {
        let queueContents = Array(acceleratorQueue)
        acceleratorQueue.removeAll()

        let csvs = queueContents
            .map(\.csv)
            .map { $0 + "\r\n"}
            .joined(separator: "\r\n")
        let csvData = csvs.data(using: .utf8)!
        writeHandle.write(csvData)
    }

    private func transmitRecords() async {
        // Wait for enough records (writingWatermark) to accumulate
        // Serialize each.
        // Aggregate into lines
        // Write it out.
        // wait for that to finish
        // wait for the acceleratorQueue to fill up again.

        // NOTE: There must be a flush for < writingWatermark at the end.
    }


}


