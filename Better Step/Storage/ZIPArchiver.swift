//
//  ZIPArchiver.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/12/23.
//

import Foundation
import ZIPFoundation

/**
 - note:
 
 A simple generator of ZIP archives.
 
 This replaces `ZIPArchiver`, which _may_ have contributed to bugs.
 
```swift
 let zArch = ZipArchiver(destinationPath: "/Users/Example/output.zip
 ...
 try arch.add(string: "When in the course of Human...",
              named: "declaration.txt")
 ...
 try arch.saveArchive()
```
 */
class ZIPArchiver: MassDiscardable {
    // MARK: - Initialization
    /// The `ZIPFoundation.Archive` to build onto
    private var archiver: Archive
    private let outputURL: URL
    
    /// Create a ``ZIPArchiver``  in "create" mode.
    /// - throws: ``AppPhaseErrors.cantCreateZIPArchive`` if `ZIPFoundation` can't create its `Archive`.
    init(destinationURL url: URL) throws {
        // FIXME: verify that the URL is not an existing directory.
        guard let arch = Archive(accessMode: .create) else {
            throw AppPhaseErrors.cantInitializeZIPArchive
        }
        self.archiver = arch
        self.outputURL = url
    }
    
    convenience init(destinationPath path: String) throws {
        guard let dest = URL(string: path) else {
            fatalError("\(#function):\(#line): No URL yield from “\(path)”")
        }
        try self.init(destinationURL: dest)
    }
    
    // MARK: - MassDiscardable
    var reversionHandler: AnyObject?

    /// ``MassDiscardable`` adoption
    func handleReversion(notice: Notification) {
        archiver = Archive(accessMode: .create)!
    }

    
    // MARK: - Insertion
    /// Compress and add `Data` to the archive under a given file name.
    /// - Parameters:
    ///   - data: The data to encode
    ///   - fileName: The "file" name that identifies `data` in the archive.
    /// - throws: Errors from `ZIPFoundation`.
    func add(_ data: Data, named fileName: String) throws {
        try archiver
            .addEntry(with: fileName,
                      type: .file,
                      uncompressedSize: Int64(data.count),
                      compressionMethod: .deflate,
                      provider: { position, size in
                return data
            })
    }
    
    /// Compress and add  a `String` to the archive under a given file name.
    /// - Parameters:
    ///   - string: The string to encode
    ///   - fileName: The "file" name that identifies `data` in the archive.
    /// - throws: Errors from `ZIPFoundation`.
    func add(string: String, named fileName: String) throws {
        guard let data = string.data(using: .utf8) else {
            fatalError("\(#fileID):\(#line) - can't convert internal String to Data")
        }
        try self.add(data, named: fileName)
    }
    
    // MARK: - Output
    var archivedData: Data? {
        archiver.data
    }
    
    /// Save the acciumulated archive data into `self.outputURL`.
    /// - throws: `AppPhaseErrors.cantGetArchiveData` if no output data is available; various Foundation errors via `FileManager`.
    func saveArchive() throws {
        guard let data = archivedData else { throw AppPhaseErrors.cantGetArchiveData }
        try FileManager.default
            .deleteAndCreate(at: outputURL,
                             contents: data)
    }
}

