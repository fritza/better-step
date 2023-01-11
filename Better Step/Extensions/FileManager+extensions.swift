//
//  FileManager+extensions.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/24/22.
//

import Foundation

#if !HAS_PHASES
public enum FileStorageErrors: Error {
    case plainFileAtURL(URL)
    case cantCreateFileAt(URL)
    case cantCreateFileTagged(SeriesTag)
    case fileExistaAlready(String)
    case directoryExistsAlready(String)
    case cantFindURL(String)
    case cantReadDictionaryAt(URL)
    case uploadEmptyData(String)
    case cantFindZIP(String)
}

public enum AppPhaseErrors: Error {
    case noSubjectID
    case cantLoadData(URL)
    case uploadEmptyData(String)
    case cantInitializeZIPArchive
    case cantGetArchiveData
    case cantInsertDataFile(fileName: String)
    case subjectIDInvalid(String)
    case shortageOfDASIResponsesBy(Int)
    case walkingPhaseProbablyKilled(SeriesTag)
    
    case NOS
}

#else

public enum FileStorageErrors: Error {
    case plainFileAtURL(URL)
    case cantCreateFileAt(URL)
    case fileExistaAlready(String)
    case directoryExistsAlready(String)
    case cantFindURL(String)
    case cantReadDictionaryAt(URL)
    case uploadEmptyData(String)
    case cantFindZIP(String)
}

public enum AppPhaseErrors: Error {
    case noSubjectID
    case cantLoadData(URL)
    case uploadEmptyData(String)
    case cantInitializeZIPArchive
    case cantGetArchiveData
    case cantInsertDataFile(fileName: String) 
    case subjectIDInvalid(String)
    case shortageOfDASIResponsesBy(Int)

    case NOS
}
#endif

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

    /// Whether a **regular file** exists at a URL.
    public func fileExists(atURL url: URL) -> Bool {
        let (exists, directory) = somethingExists(atURL: url)
        return exists && !directory
    }

    /// Whether a **directory** exists at a URL.
    public func directoryExists(atURL url: URL) -> Bool {
        let (exists, directory) = somethingExists(atURL: url)
        return exists && directory
    }

    /// Delete a **regular file** at a URL.
    ///
    /// No effect if there is no such file.
    /// - throws: `FileManager` errors.
    public func deleteIfPresent(_ url: URL) throws {
        guard fileExists(atURL: url) else { return }
        // Discard any existing file.
        try removeItem(at: url)
    }

    /// Create a **regular file** at a URL, deleting any existing file at that location.
    /// - throws `FileManager` errors, or `AppPhaseErrors.cantCreateFileAt()` if creation failed.
    public func deleteAndCreate(at url: URL,
                                contents: Data? = nil) throws {
        if fileExists(atURL: url) {
            // Discard any existing file.
            try removeItem(at: url)
        }
        guard createFile(
            atPath: url.path,
            contents: contents, attributes: nil) else {
                throw FileStorageErrors
                    .cantCreateFileAt(url)
        }
    }

    /// Create a **regular file** at a URL, deleting any existing file at that location, open it, and return the `FileHandle` for the new file.
    /// - returns the `FileHandle` for the new file.
    /// - throws: Errors thrown by `deleteAndCreate(at:)`, or FileHandle errors if the handle can't be created.
    public func deleteCreateAndOpen(_ url: URL) throws -> FileHandle {
        try deleteAndCreate(at: url)
        let retval = try FileHandle(forWritingTo: url)
        return retval
    }

    /// The `URL` of the application documents directory
    /// - warning: The OS should be able to return the `URL`, so the result is force-unwrapped.
    public var applicationDocsDirectory: URL {
        let url = self
            .urls(for: .documentDirectory,
                     in: .userDomainMask)
            .first!
        return url
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

