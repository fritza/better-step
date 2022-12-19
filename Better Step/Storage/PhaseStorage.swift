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
import ZIPFoundation



/// Maintain the data associated with completed phases of the workflow.
///
/// Watch completion of all necessary stages by observing `.isComplete`.
public final class PhaseStorage: ObservableObject
{    // FIXME: Update ASKeys for completions

    static let shared: PhaseStorage = {
        let defaults = UserDefaults.standard
        let subjectID = SubjectID.id
        assert(subjectID != SubjectID.unSet,
        "No subject ID set. Can't Happen.")

        let isLaterRun = defaults
            .bool(forKey: ASKeys.hasCompletedSurveys.rawValue)
        // (.bool(forKey:) returns false if undefined.

        return PhaseStorage(
            goal: isLaterRun ? .secondRun : .firstRun,
            subject: subjectID)
    }()

    public enum CompletionGoal {
        case firstRun
        case secondRun
    }

    typealias CompDict = [SeriesTag:Data]
    private var completionDictionary  : CompDict
    private var subjectID             : String
    private var goal                  : CompletionGoal

    /// Whether data for all phases of this run (first or later) has been acquired. It is expected that client code will watch this and write all the files out when it's all done.
    @Published public  var isComplete : Bool

    public init(goal: CompletionGoal,
                subject: String) {
        completionDictionary = [:]
        self.goal = goal
        self.isComplete = false
        self.subjectID = subject
    }


    /// Determine whether all data needed for first or subsequent sessions has arrived. Set the observable `isComplete` accordingly.
    private func checkCompletion() {
        // Do all of what I've finished...
        let finishedKeys = Set(completionDictionary.keys)
        // appear in the list of what should be finished?
        let keysToBeFinished = (goal == .firstRun) ? SeriesTag.neededForFirstRun : SeriesTag.neededForLaterRuns
        
        let intersection = finishedKeys.intersection(keysToBeFinished)
        let isCompleted = intersection == keysToBeFinished
        isComplete = isCompleted
    }


    public func series(_ tag: SeriesTag, completedWith data: Data) {
        guard !completionDictionary.keys.contains(tag) else {   // Really? Not permit correction?
            preconditionFailure("\(#function) - Attempt to re-insert \(tag.rawValue)")
        }
        completionDictionary[tag] = data
        checkCompletion()
    }

    func data(for series: SeriesTag) -> Data? {
        completionDictionary[series]
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
        phase.dataFileBasename(subjectID: subjectID)
    }

    /// The full name of the CSV file containing the subject's performance of a given phase on a given day.
    /// - Parameter phase: The phase to be reported on.
    /// - Returns: A file name of the form `subjectID_date_series.csv`
//    func dataFileFilename(phase: SeriesTag) -> String {
//        return csvFileBasename(phase: phase) + ".csv"
//    }


    /// The name of the directory within `/tmp` into which the data files are to be written and the .zip archive is to be created.
    ///
    /// No path other than the name for the directory
    /// - note: The date portion of the name is taken as a year-month-day rendering of the present moment. Strictly speaking, this is a race.
    var containerDirectoryName: String {
        let dateRep = Date().ymd
        return "\(subjectID)_\(dateRep)"
    }

    /// A `file:` URL for the container directory, concatenating the system  `/tmp` directory and the name of the container directory.
    var containerDirectoryURL: URL {
        let tempDirPath = NSTemporaryDirectory()
        let tempDirURL = URL(fileURLWithPath: tempDirPath, isDirectory: true)
            .appendingPathComponent(containerDirectoryName)
        return tempDirURL
    }
    
    /// Create the container directory (holds the .zip and .csv files) _if it doesn't already exist._
    /// - bug: The test is for whether anything, directory _or file,_ already exists. This will be trouble once the app tries to insert files into it.
    func createContainerDirectory() -> URL {
        guard !FileManager.default
            .somethingExists(atURL: containerDirectoryURL).exists
        else {
            return containerDirectoryURL
        }
        do {
            try FileManager.default
                .createDirectory(
                    at: containerDirectoryURL,
                    withIntermediateDirectories: true)
        }
        catch {
            preconditionFailure(error.localizedDescription)
        }
        return containerDirectoryURL
    }
    #warning("Whether to overwrite dir/file isn't considered")

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
        var destURL = containerDirectoryURL
        destURL
            .appendPathComponent(csvName)
        return destURL
    }

}
