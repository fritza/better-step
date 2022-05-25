//
//  AccSession+CoreDataClass.swift
//  mommk
//
//  Created by Fritz Anderson on 4/19/22.
//
//

import Foundation
import CoreData
import CoreMotion


enum OutputErrors: String, Error {
    case noAccContent = "Could not generate CSV from (empty?) element set"
    case cantMakeTempZipFile = "Could not create the uncompressed data file."
    case cantMakeZIPArchive = "initializer Archive(data:accessMode:) failed."
}

/// A managed object aggregating `AccSample` observations for a particular starting time.
///
/// Deletion of `AccSession` cascades into its `AccSample`s.
@objc(AccSession)
public class AccSession: NSManagedObject {
    /*
     @NSManaged public var start: Double
     @NSManaged public var samples: NSOrderedSet?
     @NSManaged public var subject: Subject?
     */

    /// Add a session to a `Subject`.
    /// - Parameters:
    ///   - subject: The `Subject` to attach the session to.
    ///   - date: The starting date of the session; defaults to current.
    ///   - moc: The managed-object context in which to create the session.
    /// - Returns: A new `AccSession` for the given subject.
    /// - warning: (1) this does not cancel, stop, or delete an existing session. (2) It does not save to store.
    static func newSession(forSubject subject: Subject,
                           atDate date: Date = Date(),
                           inContext moc: NSManagedObjectContext = CDGlobals.viewContext) -> AccSession {
        let object =  NSEntityDescription
            .insertNewObject(forEntityName: "AccSession",
                             into: moc) as! AccSession
        (object.subject, object.start) = (subject, date.timeIntervalSinceReferenceDate)
        return object
    }

    /// Append `CMAcceleration` as an `AccSample` to the session list.
    func add(
        acceleration: CMAcceleration,
        timestamp: TimeInterval,
        inContext moc:  NSManagedObjectContext = CDGlobals.viewContext) throws {
            let newAccRecord = AccSample.newSample(
                acceleration.x, acceleration.y, acceleration.z,
                timestamp: timestamp,
                inContext: moc)
            self.addToSamples(newAccRecord)
        }
}

import ZIPFoundation

extension AccSession {
    /// The sample records marshaled into lines of CSV.
    /// - Parameter asMagnitude: If `true`, acceleration is reported as a single magnitude; otherwise as three coordinates.
    /// - Returns: The lines reduced to `Data`, or `nil` if no records could be retrieved.
    func sessionFileContents(asMagnitude: Bool) -> Data? {
        // Ooooo… I _so_ want to retrieve the samples
        // sorted by time. Instead, see if it's reliable
        // first

        guard let sampleSet = samples else {
            return nil
            // TODO: Empty, nil, or throw?
        }

        #if DEBUG
        // Verify that the type cast works,
        // and that the elements are in time order.
        var previousTimeSeconds = -TimeInterval.infinity
        for element in sampleSet {
            guard let sample = element as? AccSample else {
                fatalError("Haven’t gotten the cast right.")
            }
            assert(sample.timeSeconds > previousTimeSeconds,
                   "\(#function) Set ordering didn't work out.")
            previousTimeSeconds = sample.timeSeconds
        }
        #endif

        let wholeString = sampleSet
            .map { $0 as! AccSample }
            .map { $0.csvLine(asMagnitude: asMagnitude)}
            .joined(separator: "\r\n")

        return wholeString.data(using: .utf8)
    }

    /// Creates a data file (`"com.drdrLabs" + uuid + ".csv"`) to receive the uncompressed CSV content.
    /// - Parameter content: The data to be written into the file. Should be lines of CSV records.
    /// - Returns: The URL of the temporary file.
    static func sessionTempFile(content: Data) throws -> URL {
        let tempFileName = "com.drdrlabs."
        + UUID().uuidString + ".csv"
        let temporaryDirectory = FileManager.default
            .temporaryDirectory
        let temporaryFileURL = temporaryDirectory.appendingPathComponent(tempFileName)

        let didCreate = FileManager.default
            .createFile(atPath: temporaryFileURL.path,
                        contents: content)
        if !didCreate { throw OutputErrors.cantMakeTempZipFile }

        return temporaryFileURL
    }


    #warning("Stopgap: Wrap DASI and steps into a single ZIP file.")
    // But that's going to be optional depending on which phases are available. For now, a single file is good enough.

    /// Zip-compress the contents of the session report file and save it to a given URL.
    /// - precondition: `url` must have the `.zip` extension (asserted). It must not exist at the time of call, and the user must have adequate privileges (throws Foundation errors).
    /// - throws: Various Foundation errors if the file already exists or the user isn't authorized to create it.
    /// - Parameter url: The URL for a new `.zip` file.
    /// - throws: Foundation errors for file operations. `ZipFoundation` errors. `OutputErrors.noAccContent` if no `AccSample`s are joined
    func saveZipped(to url: URL, asMagnitude: Bool) throws {
        assert(url.path.hasSuffix(".zip"))

        guard let data = sessionFileContents(asMagnitude: asMagnitude) else {
            throw OutputErrors.noAccContent
        }
        let sourceFile = try Self.sessionTempFile(content: data)
        let fm = FileManager.default
        try fm.zipItem(
            at: sourceFile, to: url,
            // FIXME: Am I right not to take the parent directory with me?
            shouldKeepParent: false,
            compressionMethod: .deflate)

        // Then kill the source file, right?
        try fm.removeItem(at: sourceFile)
    }
}

