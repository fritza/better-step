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
public final class CSVArchiver: MassDiscardable {
    var reversionHandler: AnyObject?

    lazy var archiveURL: URL = {
        // Just setting the archive URL
        // upon init runs the danger that
        // SubjectID.id is unset (""). making
        // all write operations to filenames that
        // lack the subject ID.
        // FIXME: Extremely bad idea to hope
        //        for a complete SubjectID if you
        //        wait until first use.
        return PhaseStorage.shared.zipOutputURL
    }()
    /// The output ZIP archive
    let archiver: Archive

    //    var cancellables: Set<AnyCancellable> = []
    
    /// Construct an `Archive` for a `.zip` file at a given URL.
    /// - Parameter destination: The fully-qualified `URL` for the output `.zip` file.
    /// - precondition: The URL must refer to a file with the `.zip` extension.
   public init() throws {
        guard let archive = Archive(accessMode: .create)
        else { throw AppPhaseErrors.cantInitializeZIPArchive }
//        self.archiveURL = PhaseStorage.zipOutputURL
        self.archiver = archive
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
    public static let noticeTagWriteKey = "writeResult"
    /// `userInfo` key for the `Error` responsible for failure to write.
    public static let noticeTagWriteErrorKey = "tagWriteErrorKey"

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
}

extension CSVArchiver {
    // MARK: Core API
    
    /// Add data under an in-archive name to the archive.
    /// - seealso: ``exportZIPFile()`
    public func add(_ data: Data, filename: String) throws {
        do {
            try archiver.addEntry(
                with: filename,
                type: .file,
                uncompressedSize: Int64(data.count),
                compressionMethod: .deflate) {
                    // "provider"
                    // This take s an offset into the
                    //
                    (position: Int64, size: Int) -> Data in
                    return data
                }
        }
        catch {
            // debugging only.
            print(#function, "- ended in error:", error)
            throw error
        }
    }
    /// Assemble and compress the file data and write it to a `.zip` file.
    ///
    /// Posts `ZIPCompletionNotice` with the URL of the product `.zip`.
    /// - warning: This function totally neglects`` SeriesWriteSucceeded`, `SeriesWriteFailed` if w
    ///
    /// - seealso: ``add(_:filename:)``
    ///
    public func exportZIPFile() throws {
        guard let content = archiver.data else {
            throw AppPhaseErrors.cantGetArchiveData
        }
        
        print("Archive at:", archiveURL)
        
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
