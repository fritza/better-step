//
//  CSVArchiver.swift
//  G Bars
//
//  Created by Fritz Anderson on 9/8/22.
//

import Foundation
//import Combine
import ZIPFoundation

// TODO: Normalized walk accelerations
//       First timestamp in the array should
//       be subtracted from all elements.

/// Accumulate data (expected `.csv`) for export into a ZIP archive.
final class CSVArchiver: MassDiscardable {
    var reversionHandler: AnyObject?

    
    var archiveURL: URL
    /// The output ZIP archive
    let archiver: Archive

    //    var cancellables: Set<AnyCancellable> = []
    
    /// Construct an `Archive` for a `.zip` file at a given URL.
    /// - Parameter destination: The fully-qualified `URL` for the output `.zip` file.
    /// - precondition: The URL must refer to a file with the `.zip` extension.
    init(into destination: URL) throws {
        precondition(destination.pathExtension == "zip",
                     "destination URL ...\(destination.lastPathComponent) lacks the “zip” extension.")
        guard let archive = Archive(
            accessMode: .create)
        else { throw AppPhaseErrors.cantInitializeZIPArchive }
        self.archiver = archive
        self.archiveURL = destination
        self.reversionHandler = installDiscardable()
    }
    
    /// Reverting ``CSVArchiver``means deleting the output
    /// file it created.
    ///
    /// Contrast with `deinit`, which _should not_ ever delete the `.zip` file.
    func handleReversion(notice: Notification) {
        do {
            try FileManager.default
                .deleteIfPresent(archiveURL)
        }
        catch {
            #if DEBUG
            print(#function, "at \(#fileID):\(#line): FM.deleteIfPresent threw",error)
            print("\tShould be harmless")
            #endif
        }
    }

    // Step 1: Create the destination directory

    // MARK: Notification
    
    /// `userInfo` key, for future use, to describe success in a write.
    static let noticeTagWriteKey = "writeResult"
    /// `userInfo` key for the `Error` responsible for failure to write.
    static let noticeTagWriteErrorKey = "tagWriteErrorKey"

    /// Post a success or failure notification
    ///
    /// Posts
    ///  - `SeriesWriteSucceeded` if writing succeeded,
    ///  - `SeriesWriteFailed` if writing failed.
    ///
    /// In a better world, _maybe_ this should be an `async` operation.
    /// - Parameters:
    ///   - phase: The `SeriesTag` for this write operation
    ///   - result: The result of that operation:, `Result<[String:Any], Error>`
    ///
    ///  - warning:  not used.
    ///
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

    @available(*, unavailable, message: "Not to be used.")
    /// **URL** of the working directory that receives the `.csv` files and the `.zip` archive.
    ///
    /// The directory is created by`createWorkingDirectory()` (`private` in this source file).
    /// **BUT NOT HERE!**
    lazy var containerDirectory: URL! = {
        return PhaseStorage.shared.createContainerDirectory()
    }()

}

extension CSVArchiver {
    // MARK: Core API
    
    /// Add data under an in-archive name to the archive.
    /// - seealso: ``exportZIPFile()`
    func add(_ data: Data, filename: String) throws {
        try archiver.addEntry(
            with: filename,
            type: .file,
            uncompressedSize: Int64(data.count)) {
                // "provider"
                // NO idea whether it's suppsed to be just the whole data.
                (position: Int64, size: Int) -> Data in
                return data
            }
    }
    /// Assemble and compress the file data and write it to a `.zip` file.
    ///
    /// Posts `ZIPCompletionNotice` with the URL of the product `.zip`.
    /// - warning: This function totally neglects`` SeriesWriteSucceeded`, `SeriesWriteFailed` if w
    ///
    /// - seealso: ``add(_:filename:)``
    ///
    func exportZIPFile() throws {
        guard let content = archiver.data else {
            throw AppPhaseErrors.cantGetArchiveData
        }
        try content.write(to: archiveURL)
        
        // Notify the export of the `.zip` file
        let params: [ZIPProgressKeys : URL] = [
            .fileURL :    archiveURL
        ]
        NotificationCenter.default
            .post(name: ZIPDataWriteCompletion,
                  object: self, userInfo: params)
    }
}


#if false
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
#endif
