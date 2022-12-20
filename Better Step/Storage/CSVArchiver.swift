//
//  CSVArchiver.swift
//  G Bars
//
//  Created by Fritz Anderson on 9/8/22.
//

import Foundation
import Combine
import ZIPFoundation

// TODO: Normalized walk accelerations
//       First timestamp in the array should
//       be subtracted from all elements.

/// Accumulate data (expected `.csv`) for export into a ZIP archive.
final class CSVArchiver {
    fileprivate static var _shared: CSVArchiver?

    // TODO: Reduce dependency on the shared
    //       OR: have a singleton PhaseStorage, which owns the archiver anyway.

        static var shared: CSVArchiver = {
            if let _shared { return _shared }
            _shared = try! CSVArchiver()
            return _shared!
        }()
    
    static func clearSharedArchiver() {
        let _ = try? FileManager.default
            .deleteObjects(at: [ shared.destinationDirectoryURL ])
        _shared = nil
    }

    /// Invariant: time of creation of the export set
    let timestamp = Date().iso
    /// The output ZIP archive
    let csvArchive: Archive

    var cancellables: Set<AnyCancellable> = []
    
    /// Capture file and directory locations and initialize the archive.
    /// - Parameter subject: The ID of the user
    init() throws {
        let backingStore = Data()
        guard let _archive = Archive(
            data: backingStore,
            accessMode: .create)
        else { throw AppPhaseErrors.cantInitializeZIPArchive }
        self.csvArchive = _archive
        
        setUpCombine()
    }

    /// Empty the container and its filesystem storage.
    ///
    func reset() {
        // This may be tricky.

        // 1. Delete the working directory,
        // which should get rid of the intermediates
        // and the ZIP file.


        // 2. Reset the archiver.
        // Can we do this just by
    }

    // Step 1: Create the destination directory

    // MARK: Working Directory

    /// **URL** of the working directory that receives the `.csv` files and the `.zip` archive.
    ///
    /// The directory is created by`createWorkingDirectory()` (`private` in this source file).
    /// **BUT NOT HERE!**
    lazy var containerDirectory: URL! = {
        return PhaseStorage.shared.createContainerDirectory()
    }()
    
    func setUpCombine() {
        PhaseStorage.shared
            .$completionDictionary
            .removeDuplicates()
            .eraseToAnyPublisher()
            .sink { [self]
                completions in
                print(#function,
                      "We're in business!")
                for (tag , data) in completions {
                    write(bytes: data, forPhase: tag)
                }
            }
            .store(in: &cancellables)
    }
    
    
    func write(bytes data: Data, forPhase tag: SeriesTag) {
        print("Series", tag.rawValue, " - ", data.count, "bytes")
        
        let fileName = PhaseStorage.shared.csvFileName(for: tag)
        do {
            let fileURL = PhaseStorage.shared.csvFileURL(for: tag)
            try FileManager.default
                .deleteAndCreate(at: fileURL,
                                 contents: data)
            // Here's where you start writing things.
            
            
            // DO WE REALLY NEED NOTIFICATIONS of in/completion?
            // Now that we're accepting all the files at once,
            // there's nothing more to coordinate, right?
        }
        catch {
            print("in csvArchiver.setUpCombine, can't save \(fileName).")
            print(error)
            preconditionFailure("Cannot proceed after FS error")
        }
    }
    

    /// Write a file containing CSV content data into the uniform holding file for one run of a walk challenge
    /// - Parameters:
    ///   - data: The data to write
    ///   - tag: The `WalkingState` for the walk phase.
    func addToArchive(data: Data, forPhase phase: SeriesTag) throws {

#if false
        fatalError("to be ported")
#else
        do {
            phaseStorage
                .series(phase, completedWith: data)


            let dataURL = try writeFile(data: data,
                                        forPhase: phase)
            try csvArchive.addEntry(
                with: dataURL.lastPathComponent,
                fileURL: dataURL)

            // REFORM:
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
#endif
    }

    static let noticeTagWriteKey = "writeResult"
    static let noticeTagWriteErrorKey = "tagWriteErrorKey"

    /// Post a success or failure notification
    /// - Parameters:
    ///   - phase: The `SeriesTag` for this write operation
    ///   - result: The result of that operation:, `.failure` or `.success`.
    ///
    ///   In the failure case,
    private func notify(phase: SeriesTag,
                        forResult result:
                        Result<[String: Any], Error>)
    {
        var userInfo: [String:Any]
        var name: Notification.Name

        switch result {
        case .success(let dict):
            name = SeriesWriteSucceeded
            userInfo = dict
        case .failure(let error):
            name = SeriesWriteFailed
            userInfo = [CSVArchiver.noticeTagWriteErrorKey: error]
        }

        NotificationCenter.default
            .post(name: name, object: self,
                  userInfo: userInfo)
    }
    //
    //
    //
    //        var userInfo = [Self.noticeTagWriteKey: phase]
    //        switch result {
    //        case .failure(let error):
    //            userInfo[Self.noticeTagWriteErrorKey] = error
    //                     NotificationCenter.default
    //                .post(name: SeriesWriteFailed,
    //                      object: self,
    //                      userInfo: userInfo)
    //
    //                     case .success(let userInfo):
    //                        NotificationCenter.default
    //                .post(name: SeriesWriteSucceeded,
    //                      object: self,
    //                      userInfo: userInfo)
    //                     }
}

#warning("Whoosh. Step through this.")

extension CSVArchiver {

    // See "writeOneFile" below
    func writeAllArchives() throws -> Bool {
        #warning("Potential circularity berween PhaseStorage and CSVArchiver .shared")
        guard PhaseStorage.shared.isComplete else {  return false }
        try
        PhaseStorage.shared.forEachPhase { seriesTag, data throws in
            // Create and populate the file
            let taggedURL =
            PhaseStorage.shared.csvFileURL(
                for: seriesTag)
            let success = FileManager.default
                .createFile(
                    atPath: taggedURL.path,
                    contents: data)
            if !success {
                NotificationCenter.default
                    .post(name: SeriesWriteFailed,
                          object: self)
                throw FileStorageErrors
                    .cantCreateFileTagged(seriesTag)
            }

            // Broadcast success for current tag.
            let params = ZIPProgressKeys.dictionary(
                phase: seriesTag, url: taggedURL)
            NotificationCenter.default
                .post(name: ZIPDataWriteCompletion,
                      object: self, userInfo: params)
        }
        // Write their data
        return true
    }

    private func writeOneFile(
        for seriesTag: SeriesTag,
        data: Data) throws {
            let taggedURL =
            PhaseStorage.shared.csvFileURL(
                for: seriesTag)
            let success = FileManager.default
                .createFile(
                    atPath: taggedURL.path,
                    contents: data)
            if !success {
                throw FileStorageErrors
                    .cantCreateFileTagged(seriesTag)
            }

            // Broadcast success for current tag.
            let params = ZIPProgressKeys
                .dictionary(
                    phase: seriesTag, url: taggedURL)
            NotificationCenter.default
                .post(name: ZIPDataWriteCompletion,
                      object: self, userInfo: params)

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

// MARK: - Directory names
extension CSVArchiver {
    var directoryName: String {
        "\(SubjectID.id)_\(timestamp)"
    }

    /// Child directory of temporaties diectory, named uniquely for this package of `.csv` files.
    fileprivate var destinationDirectoryURL: URL {
        let temporaryPath = NSTemporaryDirectory()
        let retval = URL(fileURLWithPath: temporaryPath, isDirectory: true)
            .appendingPathComponent(directoryName,
                                    isDirectory: true)
        
        assert(retval == PhaseStorage.shared.containerDirectoryURL)
        
        
        return retval
    }

}

// MARK: File names
extension CSVArchiver {

    /// target `.zip` file name
    var archiveName: String {
        "\(directoryName).zip"
    }


    /// Working directory + archive (`.zip`) name
    var zipFileURL: URL {
        containerDirectory
            .appendingPathComponent(archiveName)
    }

    /// Name of the tagged `.csv` file
    func csvFileName(phase: SeriesTag) -> String {
        PhaseStorage.shared
            .csvFileURL(for: phase)
            .lastPathComponent
    }

}
