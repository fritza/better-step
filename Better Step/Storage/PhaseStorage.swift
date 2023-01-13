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
    static let shared = PhaseStorage()
    
    var reversionHandler: AnyObject?
//    var archiver: ZIPArchiver
    let stickyYMDTag: String // "yyyy-mm-dd"
        
    typealias CompDict = [SeriesTag:Data]
    @Published private(set) var completionDictionary  : CompDict = [:]
    //    private var subjectID             : String
    //    private var goal                  : CompletionGoal
    
    /// Whether data for all phases of this run (first or later) has been acquired. It is expected that client code will watch this and write all the files out when it's all done.
    @Published public  var areAllPhasesComplete : Bool
    
    /// Initialize a `PhaseStorage` and a ``ZIPArchiver`` for it to write into
    /// - Parameter zipURL: The fully-qualified `file:` URL for the _destination ZIP file._
    public init() {
        assert(SubjectID.id != SubjectID.unSet)
        stickyYMDTag = Date().ymd
//        archiver = try! ZIPArchiver(
//            destinationURL: zipOutputURL)
        
        self.areAllPhasesComplete = false
        self.reversionHandler = installDiscardable()
        completionDictionary = [:]
    }
    
    lazy var archiver: ZIPArchiver = {
        let retval = try! ZIPArchiver(destinationURL: zipOutputURL)
        return retval
    }()
    
    /// ``MassDiscardable`` adoption
    func handleReversion(notice: Notification) {
        areAllPhasesComplete = false
        completionDictionary = [:]
        ASKeys.isFirstRunComplete = false
    }
    
    // MARK: Completion check
    var keysToBeFinished: Set<CompDict.Key> {
        ASKeys.isFirstRunComplete ?
        SeriesTag.neededForLaterRuns :
        SeriesTag.neededForFirstRun
    }
    
    lazy var zipOutputURL: URL = {
        let docsURL = try! FileManager.default
            .url(for: .documentDirectory,
                 in: .userDomainMask,
                 appropriateFor: nil, create: true)
        return docsURL
            .appendingPathComponent(zipFileName)
    }()
    
    func csvFileName(for phase: SeriesTag) -> String {
        // The csv form is:
        // phase_subject_yyyy-mm-dd.csv
        // The zip form is:
        // subject_yyyy-mm-dd.zip
        assert(SubjectID.id != SubjectID.unSet)

        return "\(phase.rawValue)_\(SubjectID.id)_\(stickyYMDTag)"
        + ".cav"
    }
    
    var zipFileName: String {
        assert(SubjectID.id != SubjectID.unSet)

        let userNameComponent = SubjectID.id
        return "\(userNameComponent)_\(stickyYMDTag)"
        + ".zip"
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
            // We have everything.
            // Write the archive out
            try createArchive()
            // Remove all state, just as in a revert-all.
            handleReversion(
                notice: Notification(name: RevertAllNotice))
        }
    }
    
    func createArchive() throws {
        // All keysToBeFinished have data.
        for tag in keysToBeFinished {
            try archiver.add(completionDictionary[tag]!,
                             named: csvFileName(for: tag))
        }
        try archiver.saveArchive()
        ASKeys.isFirstRunComplete = true
    }
    
    func writeArchive() throws {
        let data = archiver.archivedData
    }
    
//    var zipDataExists: Bool {
//        FileManager.default
//            .fileExists(atURL: zipOutputURL)
//    }
//
//    static func zipContent() throws -> Data {
//        let zoURL = shared.zipOutputURL
//        guard shared.zipDataExists else {
//            // No file to be read? Bail.
//            throw FileStorageErrors.cantFindZIP(zoURL.lastPathComponent)
//        }
//        let data = try Data(contentsOf: zoURL)
//        return data
//    }
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
