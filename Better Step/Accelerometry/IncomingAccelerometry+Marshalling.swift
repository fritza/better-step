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
            preconditionFailure("Failed to load/decode “TextXYZT.json”")
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
        return taggedRecords(tag: tag)
            .joined(separator: "\r\n")
    }

    /// A `Data` instance containing the entire text of a CSV `String`
    ///
    /// This is a simple wrapper that takes the result of `allAsCSV(withPrefix:)` and renders it as bytes.
    ///   - parameter prefix: A fragment of CSV that will be added to the front of each record. Any trailing comma at the end will be omitted.
    func allAsTaggedData(tag: SeriesTag) -> Data {
        return allTaggedCSV(tag: tag).data(using: .utf8)!
    }

    // MARK: Writing

    #warning("translate to PhaseStorage")
    func addToArchive(subjectID: String, tag: SeriesTag) throws {
        // TODO: sonstructive response to the throw.
        let data = allAsTaggedData(tag: tag)
        try CSVArchiver.shared
            .addToArchive(data: data, forPhase: tag)
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

    /*
    /// Marshall all the `CMAccelerometerData` data and write it out to a named file in the Documents directory.
    /// - Parameters:
    ///   - fileName: The base name of the target file as a `String`. No extension will be added.
    ///   - prefix: A fragment of CSV that will be added to the front of each record. Any trailing comma at the end will be omitted.
    func writeToFile(named fileName: String,
                     phase: WalkingState,
                     tag: String, subjectID: String) throws {
        precondition(!fileName.isEmpty,
                     "\(#function): empty prefix string")
        let destURL = try FileManager.default
            .docsDirectory(create: true)
            .appendingPathComponent(fileName)
            .appendingPathExtension("csv")

        try write(phase: phase, to: destURL,
                  tag: tag, subjectID: subjectID)
    }
    func outputBaseName(walkState: WalkingState) -> String {
        let isoDate = Date().iso
        let state = walkState.csvPrefix
        // Force-unwrap: The phase _will_ be .walk_N, which _will_ have a prefix.
        return "Sample-\(state!):\(isoDate)"
    }
     */
    #warning("Port walkState to seriesTag")

    //    func writeToFile(walkState: SeriesTag) throws {
    //        precondition(walkState == .firstWalk || walkState == .secondWalk,
    //                     "Unexpected walk state \(walkState)"
    //        )
    //        let baseName = outputBaseName(walkState: walkState)
    //        try writeToFile(
    //            named: baseName,
    //            linesPrefixedWith: "\(walkState.csvPrefix!),Sample")
    //    }

}
