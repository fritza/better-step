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
    
    var uploadCompleteTag: NSObjectProtocol?
    
    var reversionHandler: AnyObject?

    let stickyYMDTag: String // "yyyy-mm-dd"
        
    typealias CompDict = [SeriesTag:Data]
    /// A dictionary that maps phases to the data they generate.
    ///
    /// `checkCompletion` compares the key set with the phases reported complete, to trigger saving the data.
    @Published private(set) var completionDictionary  : CompDict = [:]
    
    /// Whether data for all phases of this run (first or later) has been acquired. It is expected that client code will watch this and write all the files out when it's all done.
    private var areAllPhasesComplete : Bool
    
//    private var uploader: ResultsUploader?
    // FIXME: Is there a reason to persist the PerformUpload?
    private var performStruct: PerformUpload?
        
    /// Initialize a `PhaseStorage` and a ``ZIPArchiver`` for it to write into
    /// - Parameter zipURL: The fully-qualified `file:` URL for the _destination ZIP file._
    public init() {
        assert(SubjectID.id != SubjectID.unSet)
        stickyYMDTag = Date().ymd
        self.areAllPhasesComplete = false
        self.reversionHandler = installDiscardable()
        completionDictionary = [:]
        self.performStruct = nil
        
        setUpCompletionHandler()
    }
    
    // Archiver maintenance
    private var _archiver: ZIPArchiver? = nil
    func clearArchiver() { _archiver = nil }
    
    @discardableResult
    func setArchiver(at url: URL) throws -> ZIPArchiver {
        let value = try ZIPArchiver(destinationURL: url)
        _archiver = value
        return value
    }
    
    var archiver: ZIPArchiver {
        guard let retval = _archiver else {
            fatalError("Attempt to retrieve archiver before it was created.")
        }
        return retval
    }
    
//    lazy var archiver: ZIPArchiver = {
//        let retval = try! ZIPArchiver(destinationURL: zipOutputURL)
//        return retval
//    }()
    
    
    private func deleteAllFiles() throws {
        try SeriesTag.allCases
            .map { csvFileName(for: $0) }
            .map { documentsDirectory.appending(component: $0 )  }
            .forEach { url in
                try FileManager.default
                    .deleteIfPresent(url)
            }
        // Delete all product files.
        _ = try FileManager.default
            .deleteIfPresent(zipOutputURL)
    }
    
    /// ``MassDiscardable`` adoption
    ///
    /// Called when a `RevertAllNotice` is broadcaset (such as when the user taps a "Gear" button (not available in the release app) to tear down _all_ application state.
    func handleReversion(notice: Notification) {
        areAllPhasesComplete = false
        completionDictionary = [:]
        
        try! deleteAllFiles()
        
        // This is TOTAL reversion,
        // forget the subject, forget completion.
        ASKeys.isFirstRunComplete = false
        clearArchiver()
    }
    
    // MARK: Completion check
    var keysToBeFinished: Set<CompDict.Key> {
        ASKeys.isFirstRunComplete ?
        SeriesTag.neededForLaterRuns :
        SeriesTag.neededForFirstRun
    }
    
    var documentsDirectory: URL {
        try! FileManager.default
            .url(for: .documentDirectory,
                 in: .userDomainMask,
                 appropriateFor: nil, create: true)
    }
    
    lazy var zipOutputURL: URL = {
        return documentsDirectory
            .appendingPathComponent(zipFileName)
    }()
    
    func csvFileName(for phase: SeriesTag) -> String {
        // The csv form is:
        // phase_subject_yyyy-mm-dd.csv
        // The zip form is:
        // subject_yyyy-mm-dd.zip
        assert(SubjectID.id != SubjectID.unSet)

        return "\(phase.rawValue)_\(SubjectID.id)_\(stickyYMDTag)"
        + ".csv"
    }
    
    var zipFileName: String {
        assert(SubjectID.id != SubjectID.unSet)
        let userNameComponent = SubjectID.id
        let retval = "\(userNameComponent)_\(stickyYMDTag)"
        + ".zip"
        return retval
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
        
        do {
            try archiver.add(data, named: csvFileName(for: tag))
            // TODO: Watchdog will likely kill this.
        }
        catch {
            print("\(#fileID):\(#line): Can’t add", data.count, "bytes for", tag.rawValue)
            print("\t", error)
            throw error
        }
        
        // Add the datum for this tag.
        completionDictionary[tag] = data
        
        // If all required tags are accounted for,
        // send it all to CSVArchiver.
        if checkCompletion() {
            
            // init(for payload: Data, named name: String)
            
            /*
             THIS MAY OR MAY NOT BE THE PLACE WHERE WE CAN INITIALIZE A FRESH ARCHIVER.
             */
            
            try! setArchiver(at: zipOutputURL)
            guard let performer = PerformUpload(
                from: zipOutputURL,
                named: zipFileName) else {
                return
            }
            performStruct = performer
            performer.doIt()
        }
    }
    
    /// Upon completion of the upload, tear down the archive file and the accumulated-data state
    ///
    /// Caleld when an upload completes, and the PhaseStorage instance must be reset to accept a new session.
    /// - Parameter success: whether the upload succeeded.
    /// - warning: releases the uploader from a callback out of the uploader. This might not go well.
    /// - note: At some point  `success` will matter,
    ///     but this hasn't been thought-out yet.
    func tearDownFromUpload(havingSucceeded success: Bool = true)
    {
        if success {
            // If this session went end-to-end
            // then anything more is after-first.
            ASKeys.isFirstRunComplete = true
        }
                
        // Unwund progress left over from this session.
        areAllPhasesComplete = false
        completionDictionary = [:]
        try? deleteAllFiles()
        clearArchiver()
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

// MARK: - Completion notification
extension PhaseStorage {
    func setUpCompletionHandler() {
        uploadCompleteTag =
        NotificationCenter.default
            .addObserver(
                forName: UploadNotification,
                object: nil, queue: .main)
        { [self] notice in
            // TODO: Check for leaks.
            guard (notice.object as? Data) != nil,
                  let userInfo = notice.userInfo,
                  let response = userInfo["response"] as? HTTPURLResponse
            else {
                fatalError("Notifcation without Data:")
            }
            
            
            // Tear down the intermediates, depending
            // on the outcome of the upload.
            let status = response.statusCode
            let goodStatus = (200..<300).contains(status)
            
            self.tearDownFromUpload(
                havingSucceeded: goodStatus)
            // FIXME: tear-down doesn't much care about success.
            // It deletes files and resets progress
            // properties regardless.
        }
    }
}

/*
 Let's put some discipline on these lazy Archive-related properties.
 
 ZIPArchive:
    There was a deadlock: Couldn't finish without initializing the `archiver` property.
    Couldn't initialize `archiver` in the property declaration, because it needs the destination URL, which needed zipOutputURL, which so far is lazy, as it depends on .zipFileName and documentsDirectory.
 
 The problem with a lazy archiver is that lazy properties delay initialization, but set the value _only once._ This means that you could try nilling-out the archiver property, or leave it in a (probably) used-up condition, but either way, whatever is stored in `archiver` is invalid.
 */
