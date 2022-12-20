//
//  IncomingAccelerometry+Marshalling.swift
//  Better Step
//
//  Created by Fritz Anderson on 10/4/22.
//

import Foundation

extension IncomingAccelerometry {
    private func marshalledRecords(tag: SeriesTag) -> [String] {
        let common = "\(tag.rawValue),\(SubjectID.id),"
        
        #if DEBUG
        guard let all = try? XYZT.sampleData() else {
            preconditionFailure("Failed to load/decode “TestXYZT.json”")
        }
        #else
        let all = self.all()
        #endif
        // firstRecord = CMAccelerometerData
        let retval = all.map(\.csvLine)
            .map { common + $0 }
        return retval
    }

    /// Supplementary marshalling which adds  prefix to each line.
    /// - Returns: An array of `Strings` consisting of `\_prefix` + "," + `marshalled record`.
    /// - warning:Removing a comma from the end of `\_prefix` is a choice of convenience over edge cases.  Clients that _want_ to interpose a comma will find there's no clean way to do it.
    func taggedRecords(tag: SeriesTag) -> [String] {
        let plainMarshalling = marshalledRecords(
            tag: tag)
        return plainMarshalling
    }

    /// A `String` containing each line of the CSV data
    ///
    /// - Returns: A single `String`, each line being the marshalling of the `CMAccelerometerData` records
    private func allTaggedCSV(tag: SeriesTag) -> String {
        #warning("Replace with [CSVRepresentable].recordsPrefixed")
        let records = taggedRecords(tag: tag)
        let retval  = records
            .joined(separator: "\r\n")
        return retval
    }

    /// A `Data` instance containing the entire text of a CSV `String`
    ///
    /// This is a simple wrapper that takes the result of `allAsCSV(withPrefix:)` and renders it as bytes.
    ///   - parameter prefix: A fragment of CSV that will be added to the front of each record. Any trailing comma at the end will be omitted.
    func allAsTaggedData(tag: SeriesTag) -> Data {
        let allRecords = allTaggedCSV(tag: tag)
        let retval = allRecords.data(using: .utf8)!
        return retval
    }

    // MARK: Writing

    /*
     
     IncomingAccelerometry no longer interacts directly with
     PhaseStorage.
     
     Which is strange, how does the completed data get into the
     series(_:completedWith:) method at all?
     
     AMSWER: WalkingContainerView.walk_N_View(ownPhase:
     
    func addToArchive(subjectID: String, tag: SeriesTag) throws {
        // TODO: sonstructive response to the throw.
        let data = allAsTaggedData(tag: tag)
//        try CSVArchiver.shared
//            .addToArchive(data: data, forPhase: tag)

        PhaseStorage.shared.series(tag, completedWith: data)

    }
    /// Write all CSV records into a file.
    /// - Parameters:
    ///   - prefix: A fragment of CSV that will be added to the front of each record. Any trailing comma at the end will be omitted. `
    ///   - url: The location of the new file.
    func write(phase: WalkingState, to url: URL,
               tag: SeriesTag, subjectID: String
    )
    throws {
        // TODO: Make it async
        let fm = FileManager.default
        let data = allAsTaggedData(tag: tag)
        try fm.deleteAndCreate(at: url, contents: data)
        //        Self.registerFilePath(url.path)
    }
     */
}
