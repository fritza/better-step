//
//  SubjectFileCoordinator.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/12/22.
//

import Foundation
import SwiftUI
import Collections

enum FileStorageErrors: Error {
    case plainFileAtURL(URL)
}


extension FileManager {
    func somethingExists(atURL url: URL)
    -> (exists: Bool, isDirectory: Bool) {
        var isDirectory: ObjCBool = false
        let result = self.fileExists(atPath: url.path,
                                   isDirectory: &isDirectory)
        return (exists: result, isDirectory: isDirectory.boolValue)
    }

    func fileExists(atURL url: URL) -> Bool {
        let (exists, directory) = somethingExists(atURL: url)
        return exists && !directory
    }

    func directoryExists(atURL url: URL) -> Bool {
        let (exists, directory) = somethingExists(atURL: url)
        return exists && directory
    }
}


final class SubjectFileCoordinator {
    enum FlatFiles: String {
        case dasiReportFile = "DASI.csv"
        case walkingReportFile = "Accelerometry.csv"
    }

    static let shared = SubjectFileCoordinator()

    static let myAppDirectoryName = "com.drdr.better-step-test"

    var subjectID: String?
    // Interesting Idea: Put the subject ID into UserDefaults.
    // Should we be picking up the magnitude setting?

    @AppStorage("reportAsMagnitude") var asMagnitude = false

    /// The documents directory. This will enclose the app's own documents directory.
    ///
    /// I believe it is not guaranteed that there will be a file at the reprorted URL. Tha's okay, because `myAppSubfolder()` does a full-path create on the application-private dorectory.
    /// - note: Callers should not assume there is anything at the `URL` result.
    var userDocumentsFolder: URL {
        let fm = FileManager.default
        let url = fm
            .urls(for: .documentDirectory,
                     in: .userDomainMask)
            .first!
        return url
    }

    var _myAppSubfolder: URL?
    /// The URL for the per-application subfolder of the documents directory.
    /// - Returns: The URL for the app's document storage.
    /// - throws: `FileManager`-related errors, plus `FileStorageErrors.plainFileAtURL(URL)` if something existed at the expected path, but it wasn't a directory.
    func myAppSubfolder() throws ->  URL {
        if let retval = _myAppSubfolder { return retval }

        let fm = FileManager.default
        let expectedURL = userDocumentsFolder
            .appendingPathComponent(Self.myAppDirectoryName, isDirectory: true)

        // Check for existing file/directory item
        let (itemExists, isDirectory) = fm.somethingExists(atURL: expectedURL)
        if itemExists && isDirectory {
            // Good news, we have a directory already
            return expectedURL
        }
        if itemExists && !isDirectory {
            // There's a file in the way
            throw FileStorageErrors.plainFileAtURL(expectedURL)
        }

        try fm.createDirectory(
            atPath: expectedURL.path,
            withIntermediateDirectories: true)

        _myAppSubfolder = expectedURL
        return expectedURL
    }
}

extension SubjectFileCoordinator {
    func directoryURLForSubject(_ subject: String,
                       creating: Bool = false) throws -> URL {
        let appFolder = try myAppSubfolder()
        let expectedURL = appFolder.appendingPathComponent(subject, isDirectory: true)

        if creating {
            try FileManager.default
                .createDirectory(
                    atPath: expectedURL.path,
                    withIntermediateDirectories: true)
        }
        return expectedURL
    }

    /// URL for a reporting csv file, creating the container directory if necessary, the empty file if requested (and not already present).
    /// - Parameters:
    ///   - purpose: The role (dasiReportFile, walkingRepoltFile) the file serves
    ///   - subject: The ID of the subject for whom the files are generated
    ///   - creating: true if an empty file of that name is to be created, Default is false.
    /// - Returns: A URL for the requested file, or `nil` if the directory is now there, but the file could not be created.
    /// - throws: FileManager errors if the directory or file are absent and could not be created.
    func fileURLFor(_ purpose: FlatFiles,
                    subject: String,
                    creating: Bool = false) throws -> URL? {
        let fm = FileManager.default
        let destination = try  directoryURLForSubject(subject, creating: true)
            .appendingPathComponent(purpose.rawValue, isDirectory: false)



        if creating {
            var isDirectory: ObjCBool = false
            let exists = fm.fileExists(
                atPath: destination.path,
                isDirectory: &isDirectory)
            guard !exists else { return nil }
            let creationSucceeded = fm
                .createFile(atPath: destination.path,
                            contents: nil)
        }

        return destination
    }

    func write(data: Data,
               subject: String,
               for purpose: FlatFiles) throws {
        let destination = try  directoryURLForSubject(subject, creating: true)
            .appendingPathComponent(purpose.rawValue, isDirectory: false)

        try FileManager.default
            .removeItem(at: destination)

        try data.write(to: destination)
    }

    func deleteContainers(subject: String) throws {
        let containerURL = try directoryURLForSubject(subject)
        do {
        try FileManager.default
            .removeItem(at: containerURL)
            }
        catch {
            #if DEBUG
            print(#function, "deletion of", containerURL.path, "failed:", error)
            #endif
            throw error
        }
    }

    // TODO: I REALLY need a way to write data asybchronously.
// Not so much for DASI, but certainly the accelerometry.
}

final class AccelerometerFileSink {
    let highWatermark = 100
    let lowWatermark  = 100
    let dequeSize     = 1_000

    var queue: Deque<AccelerometerItem>

    var subjectID: String
    let fileURL: URL
    let writeHandle: FileHandle
    let coordinator: SubjectFileCoordinator

    var acceleratorQueue: [AccelerometerItem] = []

    init?(subject: String,
          coordinator _coordinator: SubjectFileCoordinator) throws {
        coordinator = _coordinator
        subjectID = subject

        guard let _fileURL = try _coordinator
                .fileURLFor(.walkingReportFile,
                            subject: subject,
                            creating: true)
        else {
            return nil
        }

        fileURL = _fileURL
        var _queue = Deque<AccelerometerItem>()
        _queue.reserveCapacity(dequeSize)
        queue = _queue
        writeHandle = try FileHandle(
            forWritingTo: _fileURL)
    }

    func close() async throws {
        await checkQueue(force: true)
        try writeHandle.close()
    }

    func append(record: AccelerometerItem) async {
        queue.append(record)
        await checkQueue(force: false)
    }

    func append(records: [AccelerometerItem]) async {
        queue.append(contentsOf: records)
        await checkQueue(force: false)
    }

    func popItems(force: Bool) -> [AccelerometerItem]? {
        let poppable = [queue.count, lowWatermark].min()!
        guard poppable >= highWatermark || force else {
            return nil
        }
        guard poppable > 0 else { return nil }

        let tail = queue.suffix(poppable)
        let previousCount = queue.count
        queue.removeLast(poppable)
        assert(queue.count == (previousCount - poppable))
        return Array(tail)
    }

    func checkQueue(force: Bool) async {
        guard let workUnit = popItems(force: force)
        else { return }
        let csvs = workUnit
            .map(\.csv)
            .joined(separator: "\r\n")
        + "\r\n"
        let csvData = csvs.data(using: .utf8)!
        writeHandle.write(csvData)
    }

    private func transmitRecords() async {
        // Wait for enough records (writingWatermark) to accumulate
        // Serialize each.
        // Aggregate into lines
        // Write it out.
        // wait for that to finish
        // wait for the queue to fill up again.

        // NOTE: There must be a flush for < writingWatermark at the end.
    }
}


