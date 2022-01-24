//
//  FileManager+extensions.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/24/22.
//

import Foundation

extension FileManager {
    // TODO: Should ~Exist be async?
    func somethingExists(atURL url: URL)
    -> (exists: Bool, isDirectory: Bool) {
        var isDirectory: ObjCBool = false
        let result = self.fileExists(
            atPath: url.path,
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

    func deleteAndCreate(at url: URL) throws {
        if fileExists(atURL: url) {
            // Discard any existing file.
            try removeItem(at: url)
        }
        guard createFile(
            atPath: url.path,
            contents: nil, attributes: nil) else {
                throw FileStorageErrors
                    .cantCreateFileAt(url)
        }
    }

    var applicationDocsDirectory: URL {
        let url = self
            .urls(for: .documentDirectory,
                     in: .userDomainMask)
            .first!
        return url
    }

}

extension FileManager {

    /// URL for a reporting csv file (per subject/run, per purpose.
    ///
    /// If no file exists at that URL, and if `creating`, create an empty file at that location.
    /// - Parameters:
    ///   - subject: The ID of the subject/run for whom the files are generated
    ///   - purpose: The role (`dasiReportFile`, `walkingReportFile`) the file serves
    ///   - creating: `true` if an empty file of that name is to be created, Default is false.
    /// - Returns: A URL for the requested file, no matter whether it now exists.
    /// - throws: FileManager errors if the directory or file are absent and could not be created.
    func fileURLForSubjectID(
        _ subject: String,
        purpose: SubjectFileCoordinator.FlatFiles,
        creating: Bool = false) throws -> URL {
        // Where the file for this subject and purpose should be
            let retval = try self
                .directoryURLForSubjectID(
                    subject, creating: creating)
            .appendingPathComponent(purpose.rawValue, isDirectory: false)

        if creating && !self.fileExists(atURL: retval) {
            let creationSucceeded = self
                .createFile(atPath: retval.path,
                            contents: nil)
            guard creationSucceeded else {
                throw FileStorageErrors.cantCreateFileAt(retval)
            }
        }
        return retval
    }
    
    /// The URL for a directory _within_ the os-standard Documents directory for this app, uniquely named per data set (collected for a particuler subject)
    /// - parameters:
    ///     - subject: The subject Id for whom the data in this directory is collected.
    ///     - creating: If `true`, the subject's directory will be created.
    func directoryURLForSubjectID(_ subject: String,
                       creating: Bool = false) throws -> URL {
        let expectedURL = self.applicationDocsDirectory
            .appendingPathComponent(subject, isDirectory: true)

        if creating {
            try self
                .createDirectory(
                    atPath: expectedURL.path,
                    withIntermediateDirectories: true)
        }
        return expectedURL
    }


}

