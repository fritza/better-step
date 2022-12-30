//
//  PhaseStorage.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/12/22.
//

/*
 Yet another archive-structure class (I want all clients to share state) _ought_ to be unnecessary at this stage of the project.
 
 However, it has only now become clear how to integrate the files-as-Data into Archive files with common code; and to share a consistent date, series, and subject ID; plus file names.
 */

/*
 Who should do the file names?
 Can we see if we can leave CSVArchiver alone for that?
 */


import Foundation
import SwiftUI

/// Maintain the data associated with completed phases of the workflow.
///
/// Watch completion of all necessary stages by observing `.isComplete`.
public final class PhaseStorage: ObservableObject, MassDiscardable
{
    var reversionHandler: AnyObject?
    var archiver: CSVArchiver
        
    typealias CompDict = [SeriesTag:Data]
    @Published private(set) var completionDictionary  : CompDict = [:]
    //    private var subjectID             : String
    //    private var goal                  : CompletionGoal
    
    /// Whether data for all phases of this run (first or later) has been acquired. It is expected that client code will watch this and write all the files out when it's all done.
    @Published public  var areAllPhasesComplete : Bool
    
    /// Initialize a `PhaseStorage` and a ``CSVArchiver`` for it to write into
    /// - Parameter zipURL: The fully-qualified `file:` URL for the _destination ZIP file._
    /// - precondition: ``CSVArchiver`` demads that `zipURL` should end in `.zip`.
    public init() {
        completionDictionary = [:]
        archiver = try! CSVArchiver()
        self.areAllPhasesComplete = false
        self.reversionHandler = installDiscardable()
    }
    
    /// ``MassDiscardable`` adoption
    func handleReversion(notice: Notification) {
        areAllPhasesComplete = false
        completionDictionary = [:]
        // TODO: Replace the archiver.
    }
    
    // MARK: Completion check
    var keysToBeFinished: Set<CompDict.Key> {
        ASKeys.isFirstRunComplete ?
        SeriesTag.neededForLaterRuns :
        SeriesTag.neededForFirstRun
    }
    
    /// Determine whether all data needed for first or subsequent sessions has arrived. Set the observable `isComplete` accordingly.
    private func checkCompletion() -> Bool {
        // Do all of what I've finished...
        let finishedKeys = Set(completionDictionary.keys)
        // appear in the list of what should be finished?
        let completed = keysToBeFinished.isSubset(of: finishedKeys)
        areAllPhasesComplete = completed
        return completed
    }
    
    // MARK: - Completion reports
    
    /// Report to the ``PhaseStorage`` that a phase has completed with data for output.
    ///
    /// ``PhaseStorage`` retaine all plase-data pairs until all the phases needed for this session are complete. The results are then passed to ``CSVArchiver``.
    /// - Parameters:
    ///   - tag: The  ``SeriesTag`` for the completed phase.
    ///   - data: The `Data` collected for that phase.
    public func series(_ tag: SeriesTag, completedWith data: Data) throws {
        // No report for a phase should come in that isn't part of this session.
        guard keysToBeFinished.contains(tag) else {
            assertionFailure("Strange key upon completion: \(tag.rawValue)")
            return
        }
        
        // It's a smell if a phase is reported twice.
        assert(!completionDictionary.keys.contains(tag),
               "\(#function) - Attempt to re-insert \(tag.rawValue)")
        
        // Add the datum for this tag.
        completionDictionary[tag] = data
        
        // If all required tags are accounted for,
        // send it all to CSVArchiver.
        if checkCompletion() {
            // Crete the container directory
            try Self.createContainerDirectory()
            // All keysToBeFinished have data.
            for tag in keysToBeFinished {
                try archiver.add(completionDictionary[tag]!,
                                 filename: csvFileName(for: tag))
            }
            
            do {
                try archiver.exportZIPFile()
                ASKeys.isFirstRunComplete = true
            }
            catch {
                print("Writing the zip file “\(Self.zipOutputURL.lastPathComponent)”\n\n\tFailed: \(error)")
            }
            
            // TODO: Emit the archive (CSVArchiver)
            // CSVArchiver emits all into a single ".zip" via
            // - `UIActivityViewController` at first,
            // - `URLSession` eventually
            
            // No cache of the csv reports is kept.
            // TODO: Is this all the sanitizing PhaseStorage needs?
            completionDictionary = [:]
        }
    }
    
    static var zipDataExists: Bool {
        FileManager.default
            .fileExists(atURL: Self.zipOutputURL)
    }
    
    static func zipContent() throws -> Data {
        let zoURL = Self.zipOutputURL
        guard zipDataExists else {
            // No file to be read? Bail.
            throw FileStorageErrors.cantFindZIP(zoURL.lastPathComponent)
        }
        let data = try Data(contentsOf: zoURL)
        return data
    }
}

extension PhaseStorage {
    /// Pass each phase-data pair to a closure
    /// - Parameter closure: A closure that accepts a `SeriesTag` and a `Data`.
    func forEachPhase(
        closure: @escaping ((SeriesTag, Data) throws -> Void)) rethrows {
            for (k, v) in completionDictionary {
                try closure(k, v)
            }
        }
}

extension PhaseStorage {
    /// The base name (without extension) of a data file for a given subject, date, and phase: `subjectID_date_series`.
    ///     - parameter phase: The phase for which the subject data is enclosed.
    func csvFileBasename(phase: SeriesTag) -> String {
        /// Date is defaulted to today.
        phase.dataFileBasename()
    }
    
    /// The name of the directory within `/tmp` into which the data files are to be written and the .zip archive is to be created.
    ///
    /// No path other than the name for the directory
    /// - note: The date portion of the name is taken as a year-month-day rendering of the present moment. Strictly speaking, this is a race.
    static var containerDirectoryName: String {
        let dateRep = Date().ymd
        assert(SubjectID.id != SubjectID.unSet)
        return "\(SubjectID.id)_\(dateRep)"
    }
    
    /// A `file:` URL for the container directory, concatenating the system  `/tmp` directory and the name of the container directory.
    static var containerDirectoryURL: URL {
        do {
            let docsURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            return docsURL
                .appendingPathComponent(Self.containerDirectoryName)
//
//            let tempDirPath = NSTemporaryDirectory()
//            let tempDirURL = URL(fileURLWithPath: tempDirPath, isDirectory: true)
//                .appendingPathComponent(Self.containerDirectoryName)
//            return tempDirURL
        }
        catch {
            fatalError("\(#function) = ought to be able to get the user documents directory:\n\t\(error)")
        }
    }
    
    /// Create the container directory (holds the .zip and .csv files) _if it doesn't already exist._
    /// - bug: The test is for whether anything, directory _or file,_ already exists. This will be trouble once the app tries to insert files into it.
    static func createContainerDirectory() throws {
        // fm for convenience; containerURL to avoid
        // re-evaluation.
        let fm = FileManager.default
        let containerURL = containerDirectoryURL
        
        if fm.somethingExists(atURL: containerURL).exists
        {
            // TODO: Does this ever throw?
            //       If so, how to handle it?
            _ = try? fm
                .removeItem(at: containerURL)
        }
        try fm
            .createDirectory(
                at: containerURL,
                withIntermediateDirectories: true)
    }
    
    static var zipOutputURL: URL {
        let containerName = containerDirectoryURL
            .lastPathComponent
        let retval =
        containerDirectoryURL
            .appendingPathComponent(containerName)
            .appendingPathExtension("zip")
        return retval
    }
            
    //    /// Generata the base (no trailing .csv) name for a data file, building up
    //    /// - Parameters:
    //    ///   - phase: The  phase from which the .csv is to be name
    //    ///   - date: The date on which the report is made; if nil (default), today's date (e.g. 2023-01-30) is used.
    //    /// - Returns: The base name of a file for this subject, date, and phase. No directory path, no extension.
    //    /// - note: The `date` parameter is _ignored._
    //    func csvBaseName(phase: SeriesTag,
    //                      date: Date = Date()) -> String {
    //        let retval = dataFileBasename(phase: phase)
    //        return retval
    //    }
    
    func csvFileName(for tag: SeriesTag) -> String {
        let baseName = csvFileBasename(phase: tag)
        return baseName + ".csv"
    }
    
    /// The (proposed or actual) URL for a .csv data file given subject name, date, and phase.
    /// - Parameter tag: The phase in which the data was collected
    /// - Returns: A `file:/` URL for that `.csv` data file.
    func csvFileURL(for tag: SeriesTag) -> URL {
        let baseName = csvFileBasename(phase: tag)
        let csvName = baseName + ".csv"
        var destURL = Self.containerDirectoryURL
        destURL
            .appendPathComponent(csvName)
        return destURL
    }
    
//    func zipFileURL() -> URL {
//        return containerDirectory
//    }
    
}
