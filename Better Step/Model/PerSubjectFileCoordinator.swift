//
//  PerSubjectFileCoordinator.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/12/22.
//

import Foundation
import SwiftUI
import Collections

/// Vendor for URLs of output files.
final class PerSubjectFileCoordinator {
    static var shared = PerSubjectFileCoordinator()

    // TODO: zip the output directory
    // TODO: Validate ready-to-zip
    //       Both files exist
    //       are non-empty
    //       the respective sinks are closed.
    enum FlatFiles: String {
        case dasiReportFile    = "DASI.csv"
        case walkingReportFile = "Accelerometry.csv"
    }

//    let accelerometerSink: AccelerometerFileSink

    init() {    }
}

extension PerSubjectFileCoordinator {

    /// `URL` for a reporting `csv` file (per subject, per purpose).
    ///
    /// If `creating`, create an empty file at that location, deleting the existing one if necessary.
    /// - Parameters:
    ///   - subject: The ID of the subject/run for whom the files are generated
    ///   - purpose: The role (`dasiReportFile`, `walkingReportFile`) the file serves
    ///   - creating: `true` if an empty file of that name is to be created, Default is false.
    /// - Returns: A URL for the requested file, no matter whether it now exists.
    /// - throws: FileManager errors if the directory or file are absent and could not be created.
    func fileURLForSubject(
        purpose: PerSubjectFileCoordinator.FlatFiles,
        creating: Bool = false) throws -> URL
    {
        // Append the per-purpose file name to
        // the per-subject package directory.
        let retval = try self
            .directoryURLForSubject(creating: creating)
            .appendingPathComponent(
                purpose.rawValue, isDirectory: false)

        // If the client wants a real file for the URL,
        // create it.
        // NOTE: the creating param was passed on to
        //       directoryURLForSubject(_:creating:)
        if creating {
            let fm = FileManager.default
            do {
                try fm.deleteAndCreate(at: retval)
            }
            catch {
                throw FileStorageErrors
                    .cantCreateFileAt(retval)
            }
        }
        return retval
    }


    /// The URL for a directory _within_ the os-standard Documents directory for this app, uniquely named per data set (collected for a particuler subject)
    /// - parameters:
    ///     - subject: The subject Id for whom the data in this directory is collected.
    ///     - creating: If `true`, the subject's directory will be created.
    public func directoryURLForSubject(
        creating: Bool = false) throws -> URL {
            guard let subjectID = SubjectID.shared.subjectID else {
                throw FileStorageErrors.noSubjectID
            }

            let fm = FileManager.default
            let expectedURL = fm.applicationDocsDirectory
                .appendingPathComponent(subjectID, isDirectory: true)

            if creating {
                try fm
                    .createDirectory(
                        atPath: expectedURL.path,
                        withIntermediateDirectories: true)
            }
            return expectedURL
        }
}

