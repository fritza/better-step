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
    let zipFileName: String
    
    init(_ arch: Archive, name: String) throws {
        guard let archive = Archive(accessMode: .create)
        else { throw PifflErrors.badArchive }
        //        self.archiveURL = PhaseStorage.zipOutputURL
        self.archiver = archive
        self.zipFileName = name
    }
    
    func add(piffle: Piffle) throws {
        guard let data = piffle.asData else { throw PifflErrors.badData(piffle.name) }
        
        
        
        
        
        
    }
}



