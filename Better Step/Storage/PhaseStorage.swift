//
//  PhaseStorage.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/12/22.
//

import Foundation
import SwiftUI
import Combine

/// Maintain the data associated with completed phases of the workflow.
///
/// Watch completion of all necessary stages by observing `.isComplete`.
public final class PhaseStorage: ObservableObject, MassDiscardable
{
    @AppStorage(ASKeys.phaseProgress.rawValue) var lastSeenUserPhase: SeriesTag = .none
    
    static let shared = PhaseStorage()
    
    private var uploadCompleteTag: NSObjectProtocol?
    var reversionHandler: AnyObject?

    /// The year/month/day as of the creation of this `PhaseStorage`.
    private let stickyYMDTag: String // "yyyy-mm-dd"
    
    /// The subject ID as of the creation of this `PhaseStorage`.
    private let stickySubjectID: String
    
    private var cancellables: Set<AnyCancellable> = []
        
    /// Key-value pairs mapping a completed ``SeriesTag`` to its data.
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
        stickySubjectID = SubjectID.id
        self.areAllPhasesComplete = false
        self.reversionHandler = installDiscardable()
        completionDictionary = [:]
        self.performStruct = nil
        
        setUpCombine()
    }
        
    /// Delete every `.csv` and `.zip` in the documents directory.
    ///
    /// The expected use is for state reversion (``MassDiscardable``). Testing simply for the extensions may be overbroad, consider a more precise name match.
    /// - note: Added to remove external dependencies (such as ``SubjectID``)
    /// - throws: Whatever `FileManager` would throw in listing and deleting directory contents.
    private func deleteAllFiles() throws {
        let fm = FileManager.default
        let targetExtensions: Set = [".csv", ".zip"]
        let dirURL = documentsDirectory
        
        // Verify that the documents directory exists and is not empty.
        guard fm.directoryExists(atURL: dirURL),
              let fileNames = try? fm.contentsOfDirectory(at: dirURL),
              !fileNames.isEmpty
        else { return }
        
        // Pass every file that has the `csv` or `zip` extension
        let urls = fileNames.filter { name in
            for ext in targetExtensions {
                if name.hasSuffix(ext) { return true }
            }
            return false
        }
        // Convert the file name to a URL
            .map { dirURL.appending(component: $0, directoryHint: .notDirectory)
            }
        // Delete what's at the URL.
        try fm.deleteObjects(at: urls)
    }
    
    /// ``MassDiscardable`` adoption
    ///
    /// Called when a `RevertAllNotice` is broadcaset (such as when the user taps a "Gear" button (not available in the release app) to tear down _all_ application state.
    func handleReversion(notice: Notification) {
        areAllPhasesComplete = false
        completionDictionary = [:]
        lastSeenUserPhase = .none
        try! deleteAllFiles()
        
        // This is TOTAL reversion,
        // forget the subject, forget completion.
        ASKeys.isFirstRunComplete = false
    }
    
    // MARK: Completion check
    private var keysToBeFinished: Set<CompDict.Key> {
        ASKeys.isFirstRunComplete ?
        SeriesTag.neededForLaterRuns :
        SeriesTag.neededForFirstRun
    }
    
    private var documentsDirectory: URL {
        try! FileManager.default
            .url(for: .documentDirectory,
                 in: .userDomainMask,
                 appropriateFor: nil, create: true)
    }
    
    /// The URL to receive the compressed ZIP archive.
    /// - warning: This file must not exist when its ``ZIPArchiver`` is initialized.
    lazy var zipOutputURL: URL = {
        return documentsDirectory
            .appendingPathComponent(zipFileName)
    }()
    
    /// The name of a `.csv` file to receive the data from a phase.
    private
    func csvFileName(for phase: SeriesTag) -> String {
        // The csv form is:
        // phase_subject_yyyy-mm-dd.csv
        // The zip form is:
        // subject_yyyy-mm-dd.zip
        assert(stickySubjectID != SubjectID.unSet)

        return "\(phase.rawValue)_\(stickySubjectID)_\(stickyYMDTag)"
        + ".csv"
    }
    
    /// The name of the `.zip` archive to be constructed from the `.csv` files.
    private
    var zipFileName: String {
        assert(stickySubjectID != SubjectID.unSet)
        let userNameComponent = stickySubjectID
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
    
    /// For each data in `completionDictioinary`, write it into a `ZIPArchiver`
    fileprivate func createArchive() throws {
        var okayTag: SeriesTag? = nil
        var latestFileLength = 0
        do {
            // Get any existing file out of the way.
            try FileManager.default.deleteIfPresent(zipOutputURL)
            // Add all phase/data pairs to a fresh ``ZIPArchiver``.
            var archiver = try! ZIPArchiver(destinationURL: zipOutputURL)
            try forEachPhase { tag, data in
                latestFileLength = data.count
                okayTag = tag
                try archiver.add(data, named: self.csvFileName(for: tag))
            }
            // Note: The ZIPArchive has no life outside this block.
        }
        catch {
            let failingTagName = okayTag?.rawValue ?? "<other>"
            print("\(#fileID):\(#line): Can’t add", latestFileLength, "bytes for", failingTagName)
            print("\t", error)
            throw error
        }
    }
    
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
        
        // Record the `.csv` file data under the phase that collected it.
        completionDictionary[tag] = data
        lastSeenUserPhase = tag
        
        // If all required tags are accounted for, send it all to `CSVArchiver`.
        if checkCompletion() {
            // Insert .csv for all phases into an archiver.
            try! createArchive()

            // Set up the upload with the URL for the archive.
            guard let performer = PerformUpload(
                from: zipOutputURL,
                named: zipFileName) else {
                return
            }
            performStruct = performer
            // Perform the upload.
            performer.doIt()
        }
    }
    
}

extension PhaseStorage {
    /// Pass each phase-data pair to a closure
    /// - Parameter closure: A closure that accepts a `SeriesTag` and a `Data`.
    private func forEachPhase(
        closure: @escaping ((SeriesTag, Data) throws -> Void)) rethrows {
            for (k, v) in completionDictionary {
                try closure(k, v)
            }
        }
}

// MARK: - Completion notification
extension PhaseStorage {
    
    /// Monitor a `UserDefaults` publisher.
    ///
    /// **`UploadNotification`**: The upload completed without (internal) error. Examine the status code for
    /// transaction success or failure, and resets state
    /// accordingly.
    ///
    /// Extracts the `Response`, checks the status code and sinks whether the transaction went through without any level of error:
    ///
    /// * set all phases completed to false as to the next session.
    /// * completion dictionary empty to receive new data
    /// * all incidental files removed.
    /// * If good, note that the first run is complete.
    ///
    /// - bug: Handles the (system) error case by `fatalError()`
    func setUpCombine() {
        // FIXME: Percolate the error up to user-visible alert
        //             See `#warning` in `UploadCompletionNotification.swift`.
        anyDataReleasePublisher
            .map { (notice: Notification) -> HTTPURLResponse in
                guard (notice.object as? Data) != nil,
                      let userInfo = notice.userInfo,
                      let response = userInfo["response"] as? HTTPURLResponse
                else {
                    fatalError("Notifcation without Data:")
                }
                return response
            }
            .map { (response: HTTPURLResponse) -> Bool in
                let status = response.statusCode
                let goodStatus = (200..<300).contains(status)
                return goodStatus
            }
            .sink { good in
                if good {
                    // If this session went end-to-end
                    // then anything more is after-first.
                    ASKeys.isFirstRunComplete = true
                }
                self.areAllPhasesComplete = false
                self.completionDictionary = [:]
                try? self.deleteAllFiles()
                
                // Somebody ought to post an error alert.
            }
            .store(in: &cancellables)
    }
}
