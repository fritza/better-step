//
//  ZIPFactory.swift
//  Exercise ZIP
//
//  Created by Fritz Anderson on 1/10/23.
//

import Foundation
import ZIPFoundation

final class ZipFactory {
    let archiver: Archive
    
    /// Create a ZIPFoundation Archive to be assembled and emitted solely as `Data`
    ///
    /// In other words, all "files" in the archiving process are in-memory `Data`.
    init() throws {
        guard let archive = Archive(accessMode: .create)
        else { throw PifflErrors.badArchive }
        self.archiver = archive
    }
    
    /// Extract the archive content as of the last ``add(piffle:)``.
    /// - Returns: The current data content of the archive
    /// - throws: ``PifflErrors.badArchive`` if the archiver yields `nil`.
    func data() throws -> Data {
        guard let retval = archiver.data else { throw PifflErrors.badArchive }
        return retval
    }
    
    /// Take the `Data` representation of a ``Piffle`` add it to the archive under its `name` attribute.
    ///
    /// Note that no actual file is written.
    /// - Parameter piffle: The   ``Piffle`` to encode.
    /// - Precondition: `piffle.name` shoud end with a file extension
    func add(piffle: Piffle) throws {
        guard let data = piffle.asData else { throw PifflErrors.badData(piffle.name) }
        
        try archiver
            .addEntry(with: piffle.name,
                      type: .file,
                      uncompressedSize: Int64(data.count),
                    // CHECK: .deflate doesn't break the archiver.
                      compressionMethod: .deflate,
                      provider: { position, size in
                return data
            })
        print(#function, "made it through")
    }
}
