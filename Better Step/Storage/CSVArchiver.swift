//
//  CSVArchiver.swift
//  G Bars
//
//  Created by Fritz Anderson on 9/8/22.
//

import Foundation
import ZIPFoundation

// Whew. A notification.
/// `Notification` for the addition of a (intended) `.csv` file.
let ZIPProgressNotice = Notification.Name(rawValue: "zipProgressNotice")
enum ZIPProgressKeys: String {
    // String, which phase tag has been completed.
    /// The tag (`String`) inserted into CSV lines and file names.
    case tagCompleted
    /// The name of the generated `.csv` file
    case fileName
}

/// `Notification` for the completion of the `.zip` file.
let ZIPCompletionNotice = Notification.Name(rawValue: "zipCompletionNotice")
enum ZIPCompletionKeys: String {
    /// URL for the generated .zip file
    case zipFileURL
}



// Where do I receive this notification?

/*
 1. The outer loop for archiving is a per-tag process of generating data and adding it to the archive.
 2. The generator is CSVArchiver. There is one per archive chunk, one per tag. It's a persistent object.
 3. DigitalTimerView
 4. It cannot be a TimedWalk observer; a fresh one is constructed with each DigitalTimerView
 5. MotionManager (.shared) generates the records for the chunk. It emits to TimedWalkObserver (start() async), which starts and stops it.
 6. TimedWalkObserver appends each measurement (CMAccelerometerData) by comsumer.append()
 7. Consumer (TimedWalkObserver) is an array of AccelerometerDataContent.
 8. AccelerometerDataContent is a protocol that matches CMAccelerometerData.
 9. CMAccelerometerData can emit a .csvLine (CSVRepresentable).
 */

var completedTags: [String] = []
let addToArchive = NotificationCenter.default
    .addObserver(forName: ZIPProgressNotice,
                 object: nil, queue: .main) { notice in
        guard let info = notice.userInfo as? [ZIPProgressKeys: String],
                let fileName = info[.fileName],
                let theTag   = info[.tagCompleted]
        else {
            fatalError()
        }
        completedTags.append(theTag)
        if completedTags.count == 2 {
            try! CSVArchiver.shared.exportZIPFile()
        }
    }


/// Accumulate data (expected `.csv`) for export into a ZIP archive.
final class CSVArchiver {
    static let shared = try! CSVArchiver()

    /// Invariant: time of creation of the export set
    let timestamp = Date().iso
    /// The output ZIP archive
    let csvArchive: Archive

    /// Capture file and directory locations and initialize the archive.
    /// - Parameter subject: The ID of the user
    init() throws {
        let backingStore = Data()
        guard let _archive = Archive(
            data: backingStore,
            accessMode: .create)
        else { throw FileStorageErrors.cantInitializeZIPArchive }
        self.csvArchive = _archive
    }

    // Step 1: Create the destination directory

    // MARK: Working Directory

    /// **URL** of the working directory that receives the `.csv` files and the `.zip` archive.
    ///
    /// The directory is created by ``createWorkingDirectory()``
    lazy var containerDirectory: URL! = {
        do {
            try FileManager.default
                .createDirectory(
                    at: destinationDirectoryURL,
                    withIntermediateDirectories: true)
        }
        catch {
            preconditionFailure(error.localizedDescription)
        }
        return destinationDirectoryURL

    }()

    /// **Create** the file directory to receive the `.csv` files.
    ///
    /// Name/URL from ``containerDirectory``
    private func createWorkingDirectory() -> URL {
        do {
            try FileManager.default
                .createDirectory(
                    at: destinationDirectoryURL,
                    withIntermediateDirectories: true)
        }
        catch {
            preconditionFailure(error.localizedDescription)
        }
        return destinationDirectoryURL
    }

    /// Write data into one `.csv` file in the working directory and add it to the `.zip` archive
    /// - Parameters:
    ///   - data: The content of the file to archive.
    ///   - tag: A short `String` distinguishing the phase (regular, fast) of collection.
    func writeData(_ data : Data,
                   forTag tag : String) throws {
        // TODO: Replace duplicate-named files with the new one.
        // Create and write a csv file for the data.
        let taggedURL = csvFileURL(tag: tag)
        let success = FileManager.default
            .createFile(
                atPath: taggedURL.path,
                contents: data)
        if !success {
            throw FileStorageErrors.cantCreateFileAt(taggedURL)
        }

        // Add to archive
        try csvArchive.addEntry(
            with: taggedURL.lastPathComponent,
            fileURL: taggedURL)

        // Notify the addition of the file
        let params: [ZIPProgressKeys : String] = [
            .tagCompleted : tag,
            .fileName     : taggedURL.path
          ]
        NotificationCenter.default
            .post(name: ZIPProgressNotice,
                  object: self, userInfo: params)
    }

    /// Assemble and compress the file data and write it to a `.zip` file.
    ///
    /// Posts `ZIPCompletionNotice` with the URL of the product `.zip`.
    func exportZIPFile() throws {
        guard let content = csvArchive.data else {
            throw FileStorageErrors.cantGetArchiveData
        }
        try content.write(to: zipFileURL)

        // Notify the export of the `.zip` file
        let params: [ZIPCompletionKeys : URL] = [
            .zipFileURL :    zipFileURL
          ]
        NotificationCenter.default
            .post(name: ZIPCompletionNotice,
                  object: self, userInfo: params)
    }
}

// MARK: - File names
extension CSVArchiver {
    var directoryName: String {
        "\(SubjectID.id)_\(timestamp)"
    }

    /// target `.zip` file name
    var archiveName: String {
        "\(directoryName).zip"
    }

    /// Child directory of temporaties diectory, named uniquely for this package of `.csv` files.
    private var destinationDirectoryURL: URL {
        let temporaryPath = NSTemporaryDirectory()
        let retval = URL(fileURLWithPath: temporaryPath, isDirectory: true)
            .appendingPathComponent(directoryName,
                                    isDirectory: true)
        return retval
    }

    /// Working directory + archive (`.zip`) name
    var zipFileURL: URL {
        containerDirectory
            .appendingPathComponent(archiveName)
    }

    /// Name of the tagged `.csv` file
    func csvFileName(tag: String) -> String {
        "\(SubjectID.id)_\(tag)_\(timestamp).csv"
    }

    /// Destination (wrapper) directory + per-exercise `.csv` name
    func csvFileURL(tag: String) -> URL {
        containerDirectory
            .appendingPathComponent(csvFileName(tag: tag))
    }
}
