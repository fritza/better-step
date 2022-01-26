//
//  FileManager+extensions.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/24/22.
//

import Foundation


import Foundation

public enum FileStorageErrors: Error {
    case plainFileAtURL(URL)
    case cantCreateFileAt(URL)
}

extension FileManager {
    // TODO: Should ~Exist be async?
    public func somethingExists(atURL url: URL)
    -> (exists: Bool, isDirectory: Bool) {
        var isDirectory: ObjCBool = false
        let result = self.fileExists(
            atPath: url.path,
            isDirectory: &isDirectory)
        return (exists: result, isDirectory: isDirectory.boolValue)
    }

    public func fileExists(atURL url: URL) -> Bool {
        let (exists, directory) = somethingExists(atURL: url)
        return exists && !directory
    }

    public func directoryExists(atURL url: URL) -> Bool {
        let (exists, directory) = somethingExists(atURL: url)
        return exists && directory
    }

    public func deleteAndCreate(at url: URL) throws {
        if fileExists(atURL: url) {
            // Discard any existing file.
            try removeItem(at: url)
        }
        guard createFile(
            atPath: url.path,
            contents: nil, attributes: nil) else {
                throw FileStorageErrors
                    .cantCreateFileAt(url)
        }
    }

    public var applicationDocsDirectory: URL {
        let url = self
            .urls(for: .documentDirectory,
                     in: .userDomainMask)
            .first!
        return url
    }

}

extension FileManager {
    #if FOR_BETTER_ST
    /// **Better Step only:** `URL` for a reporting `csv` file (per subject/run, per purpose.
    ///
    /// If no file exists at that URL, and if `creating`, create an empty file at that location.
    /// - Parameters:
    ///   - subject: The ID of the subject/run for whom the files are generated
    ///   - purpose: The role (`dasiReportFile`, `walkingReportFile`) the file serves
    ///   - creating: `true` if an empty file of that name is to be created, Default is false.
    /// - Returns: A URL for the requested file, no matter whether it now exists.
    /// - throws: FileManager errors if the directory or file are absent and could not be created.
    func fileURLForSubjectID(
        _ subject: String,
        purpose: SubjectFileCoordinator.FlatFiles,
        creating: Bool = false) throws -> URL {
        // Where the file for this subject and purpose should be
            let retval = try self
                .directoryURLForSubjectID(
                    subject, creating: creating)
            .appendingPathComponent(purpose.rawValue, isDirectory: false)

        if creating && !self.fileExists(atURL: retval) {
            let creationSucceeded = self
                .createFile(atPath: retval.path,
                            contents: nil)
            guard creationSucceeded else {
                throw FileStorageErrors.cantCreateFileAt(retval)
            }
        }
        return retval
    }
    #endif

    /// The URL for a directory _within_ the os-standard Documents directory for this app, uniquely named per data set (collected for a particuler subject)
    /// - parameters:
    ///     - subject: The subject Id for whom the data in this directory is collected.
    ///     - creating: If `true`, the subject's directory will be created.
    public func directoryURLForSubjectID(_ subject: String,
                       creating: Bool = false) throws -> URL {
        let expectedURL = self.applicationDocsDirectory
            .appendingPathComponent(subject, isDirectory: true)

        if creating {
            try self
                .createDirectory(
                    atPath: expectedURL.path,
                    withIntermediateDirectories: true)
        }
        return expectedURL
    }
}

extension FileManager {
    // Extensions from a playground, probably useful.

    /// Colloquial description of whether a URL points to a directory, or nothing at all.
    public func whatsThere(at url: URL) -> String {
        let (isAnything, isDirectory) = somethingExists(atURL: url)

        switch (isAnything, isDirectory) {
        case (false, _):
            return "Nothing there"
        case (true, false):
            return "Something, but not a directory"
        case (true, true):
            return "There's a directory there."
        }
    }

    /// The URL of the application `documentDirectory`.
    /// - throws: Whatever the underlying `FileManager` method throws.
    public func docsDirectory(create: Bool = false) throws -> URL {
        let url = try url(
            for: .documentDirectory,
               in: .userDomainMask, appropriateFor: nil, create: create)
        return url
    }

    /// List the names of files in a directory.
    /// - throws: Whatever the `FileManager`'s string-based `contentsOfDirectory(atPath:)` throws.
    public func contentsOfDirectory(at url: URL) throws -> [String] {
        try contentsOfDirectory(
            atPath: docsDirectory().path)
    }

    /// Traverse the file tree from a root directory, separately accumulating the URLs of each visible file or directory.
    /// - parameter url: the directory to be iterated. Behavior is undefined if `url` is not a `file` URL pointing to an existing directory,
    /// - returns: A pair of `[URL]`, listing `URL`s of the child contents listing regular files first, then directories.
    /// - throws: A `URL`-related Foundation error should any result URL not yield `resourceValues(forKeys:)`.
    public func recursiveContentsOf(directory url: URL) throws -> (regular: [URL], directory: [URL]) {
        var regulars: [URL] = []
        var directories: [URL] = []

        // The enumerator should yield only directories and regular files that aren't in package directories.
        // The candidate URL should have its type (file/dir) preloaded.
        let optionList: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles, .skipsPackageDescendants]
        let keyList = [URLResourceKey.isDirectoryKey, URLResourceKey.isRegularFileKey]

        // The tree-traversal enumerator
        guard let treeTracer = enumerator(
            at: url, includingPropertiesForKeys: keyList,
            options: optionList)
        else {
            print("\(#file):\(#line) - Couldn't create enumerator.")
            return ([], [])
        }

        // Examine each visible file and directory
        for fileObject in treeTracer {
            guard let itemURL = fileObject as? URL else {
                continue
            }
            let fileResources = try itemURL.resourceValues(forKeys: Set(keyList))
            if let isFile = fileResources.isRegularFile
                , isFile {
                regulars.append(itemURL)
            }
            else if let isDirectory = fileResources.isDirectory,
                    isDirectory {
                directories.append(itemURL)
            }
        }
        return (regular: regulars, directory: directories)
    }

    /// Mass deletions of files and directories at the `URL`s in a list.
    /// - warning: This is equivalent to `rm -r`. Any directory identified in `urls` will be deteted _along with its contents._
    /// - Parameter urls: The URLs of the files and directories to be deleted
    /// - throws: Any Foundation `Error` arising from the `FileManager.removeItem(at:)`
    public func deleteObjects(at urls: [URL]) throws {
        for url in urls {
            try removeItem(at: url)
        }
    }
}

extension URL {
    // Utility developed in a playground.

    /// The last `n` components of the `URL`.
    /// - parameter: n: How many trailing components to include.
    /// - warning: Behavior when `n < 0` is undefined.
    public func suffix(_ n: Int) -> String {
        switch n {
        case 0: return ""
        case 1: return self.lastPathComponent
        default: break
        }
        let comps = self.pathComponents
        let tail = comps.suffix(n)
        return tail.joined(separator: "/")
    }
}

