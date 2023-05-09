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
class ZIPArchiver // : MassDiscardable
{
    // MARK: - Initialization
    /// The `ZIPFoundation.Archive` to build onto
    internal var archiver: Archive
    private let outputURL: URL
    
    /// The directory to receive the csv and zip files.
    /// - note: The caller is responsible for ensuring it exists.
    var containmentURL: URL {
        outputURL.deletingLastPathComponent()
    }
    
    /// Create a ``ZIPArchiver``  in "create" mode.
    /// - parameter url: The complete URL, uncluding file name, of the archive to be created.
    /// - throws: ``AppPhaseErrors.cantCreateZIPArchive`` if `ZIPFoundation` can't create its `Archive`.
    init(destinationURL url: URL) throws {
        // FIXME: verify that the URL is not an existing directory.
        
        // My bet is that the archiver wants the file not to exist.
        do {
            try FileManager.default.deleteIfPresent(url)
        }
        catch {
            print("\(#function):\(#line) - deleteIfPresent returned an error:", error)
            throw error
        }
        
        // From README.md:
        guard let archive = Archive(url: url, accessMode: .create) else  {
            throw AppPhaseErrors.cantCreateZIPArchive
        }
        
        self.archiver = archive
        self.outputURL = url
    }
    
    // MARK: - MassDiscardable
    /// ``MassDiscardable`` adoption
//    func handleReversion(notice: Notification) {
//        archiver = Archive(accessMode: .create)!
//    }

    
    // MARK: - Insertion
    /// Compress and add `Data` to the archive under a given file name.
    /// - Parameters:
    ///   - data: The data to encode
    ///   - fileName: The "file" name that identifies `data` in the archive.
    /// - throws: Errors from `ZIPFoundation`.
    func add(_ data: Data, named fileName: String) throws {
        assert(fileName.hasSuffix(".csv"),
        "the proposed file name “\(fileName)” has the wrong extension.")
        
        let fileURL = containmentURL
            .appending(component: fileName)
        // Create a file containing the CSV,
        // using the set name for the activity,
        // date, and subject.
        try FileManager.default
            .deleteAndCreate(at: fileURL,
                             contents: data)
        
        do {
            try archiver.addEntry(with: fileName, relativeTo: containmentURL, compressionMethod: .deflate)
        }
        catch {
            print("Can’t add file", fileName, "-", error)
            throw AppPhaseErrors.cantInsertDataFile(fileName: fileName)
        }
    }
}

