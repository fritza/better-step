//
//  FileManager+extensions.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/24/22.
//

import Foundation

extension FileManager {
    // TODO: Should ~Exist be async?
    func somethingExists(atURL url: URL)
    -> (exists: Bool, isDirectory: Bool) {
        var isDirectory: ObjCBool = false
        let result = self.fileExists(
            atPath: url.path,
            isDirectory: &isDirectory)
        return (exists: result, isDirectory: isDirectory.boolValue)
    }

    func fileExists(atURL url: URL) -> Bool {
        let (exists, directory) = somethingExists(atURL: url)
        return exists && !directory
    }

    func directoryExists(atURL url: URL) -> Bool {
        let (exists, directory) = somethingExists(atURL: url)
        return exists && directory
    }

    func deleteAndCreate(at url: URL) throws {
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
}
