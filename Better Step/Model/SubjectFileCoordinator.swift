//
//  SubjectFileCoordinator.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/12/22.
//

import Foundation
import SwiftUI
import Collections

final class SubjectFileCoordinator {
    // TODO: zip the output directory
    // TODO: Validate ready-to-zip
    //       Both files exist
    //       are non-empty
    //       the respective sinks are closed.
    enum FlatFiles: String {
        case dasiReportFile = "DASI.csv"
        case walkingReportFile = "Accelerometry.csv"
    }

    let accelerometerSink: AccelerometerFileSink

    init(subjectID: String) throws {
        self.subjectID = subjectID
        accelerometerSink = try AccelerometerFileSink(subject: subjectID)
    }

    static let myAppDirectoryName = "com.drdr.better-step-test"

    var subjectID: String?
    // Interesting Idea: Put the subject ID into UserDefaults.
    // Should we be picking up the magnitude setting?

    @AppStorage("reportAsMagnitude") var asMagnitude = false
}

extension SubjectFileCoordinator {
/*
    /// URL for a reporting csv file (per subject/run, per purpose.
    ///
    /// If no file exists at that URL, and if `creating`, create an empty file at that location.
    /// - Parameters:
    ///   - subject: The ID of the subject/run for whom the files are generated
    ///   - purpose: The role (`dasiReportFile`, `walkingReportFile`) the file serves
    ///   - creating: `true` if an empty file of that name is to be created, Default is false.
    /// - Returns: A URL for the requested file, no matter whether it now exists.
    /// - throws: FileManager errors if the directory or file are absent and could not be created.
    func fileURLForSubjectID(_ subject: String, purpose: FlatFiles,
                             creating: Bool = false) throws -> URL {
        let fm = FileManager.default

        // Where the file for this subject and purpose should be
        let retval = try  directoryURLForSubjectID(subject, creating: true)
            .appendingPathComponent(purpose.rawValue, isDirectory: false)

        if creating && !fm.fileExists(atURL: retval) {
            let creationSucceeded = fm
                .createFile(atPath: retval.path,
                            contents: nil)
            guard creationSucceeded else {
                throw FileStorageErrors.cantCreateFileAt(retval)
            }
        }
        return retval
    }
*/
    func write(data: Data,
               subject: String,
               for purpose: FlatFiles) throws {
        let fm = FileManager.default
        let destination = try  fm
            .directoryURLForSubjectID(subject, creating: true)
            .appendingPathComponent(purpose.rawValue, isDirectory: false)

        try fm.removeItem(at: destination)
        try data.write(to: destination)
    }

    func deleteContainers(subject: String) throws {
        let fm = FileManager.default
        let containerURL = try fm.directoryURLForSubjectID(subject)
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

