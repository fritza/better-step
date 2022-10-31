//
//  CSVArchiver.swift
//  G Bars
//
//  Created by Fritz Anderson on 9/8/22.
//

import Foundation
import ZIPFoundation

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

//var completedTags: [String] = []


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
        else { throw AppPhaseErrors.cantInitializeZIPArchive }
        self.csvArchive = _archive
    }

    // Step 1: Create the destination directory

    // MARK: Working Directory

    /// **URL** of the working directory that receives the `.csv` files and the `.zip` archive.
    ///
    /// The directory is created by`createWorkingDirectory()` (`private` in this source file).
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

    /// Write data into one `.csv` file in the working directory .
    /// - Parameters:
    ///   - data: The content of the file to archive.
    ///   - tag: A short `String` distinguishing the phase (walk 1 or 2) of collection. Expected to be derived from WalkingPhase
    func writeFile(data : Data, forPhase phase: WalkingState) throws -> URL {
        // TODO: Replace duplicate-named files with the new one.
        // Create and write a csv file for the data.
        let taggedURL = csvFileURL(phase: phase)
        let success = FileManager.default
            .createFile(
                atPath: taggedURL.path,
                contents: data)
        if !success {
            throw FileStorageErrors.cantCreateFileAt(taggedURL)
        }

        // Notify the write of the file
        let params = ZIPProgressKeys.dictionary(
            phase: phase, url: taggedURL)
        NotificationCenter.default
            .post(name: ZIPDataWriteCompletion,
                  object: self, userInfo: params)
        return taggedURL
    }

    /// Write a file containing CSV content data into the uniform holding file for one run of a walk challenge
    /// - Parameters:
    ///   - data: The data to write
    ///   - tag: The `WalkingState` for the walk phase.
    func addToArchive(data: Data, forPhase phase: WalkingState) throws {
        do {
            let dataURL = try writeFile(data: data,
                                       forPhase: phase)
            try csvArchive.addEntry(
                with: dataURL.lastPathComponent,
                fileURL: dataURL)

            let params = ZIPProgressKeys.dictionary(
                phase: phase, url: dataURL)
            NotificationCenter.default
                .post(name: ZIPDataArchiveCompletion,
                      object: self, userInfo: params)
        }
        catch {
            let params = ZIPProgressKeys.dictionary(error: error)
            NotificationCenter.default
                .post(name: ZIPDataArchiveCompletion,
                      object: self, userInfo: params)
            throw error
        }
    }


    /// Assemble and compress the file data and write it to a `.zip` file.
    ///
    /// Posts `ZIPCompletionNotice` with the URL of the product `.zip`.
    func exportZIPFile() throws {
        guard let content = csvArchive.data else {
            throw AppPhaseErrors.cantGetArchiveData
        }
        try content.write(to: zipFileURL)

        // Notify the export of the `.zip` file
        let params: [ZIPProgressKeys : URL] = [
            .fileURL :    zipFileURL
        ]
        NotificationCenter.default
            .post(name: ZIPDataWriteCompletion,
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
    func csvFileName(phase: WalkingState) -> String {
        "\(SubjectID.id)_\(phase.csvPrefix!)_\(timestamp).csv"
    }

    /// Destination (wrapper) directory + per-exercise `.csv` name
    func csvFileURL(phase: WalkingState) -> URL {
        containerDirectory
            .appendingPathComponent(
                csvFileName(phase: phase))
    }
}
