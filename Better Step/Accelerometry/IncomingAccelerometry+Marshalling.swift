//
//  IncomingAccelerometry+Marshalling.swift
//  Better Step
//
//  Created by Fritz Anderson on 10/4/22.
//

import Foundation

extension IncomingAccelerometry {
    private var tagAndID: String {
        "\(phase.csvPrefix!),\(SubjectID.id)"
    }

    private func marshalledRecords() -> [String] {
        let all = self.all()
        let strings = all.map(\.csvLine)
        return strings
    }

    /// Supplementary marshalling which adds  prefix to each line.
    /// - Returns: An array of `Strings` consisting of `\_prefix` + "," + `marshalled record`.
    /// - warning:Removing a comma from the end of `\_prefix` is a choice of convenience over edge cases.  Clients that _want_ to interpose a comma will find there's no clean way to do it.
    private func taggedRecords() -> [String] {
        let plainMarshalling = marshalledRecords()
        return plainMarshalling
            .map { tagAndID + "," + $0}
    }

    /// A `String` containing each line of the CSV data
    ///
    /// - Returns: A single `String`, each line being the marshalling of the `CMAccelerometerData` records
    private func allTaggedCSV() -> String {
        return taggedRecords()
            .joined(separator: "\r\n")
    }

    /// A `Data` instance containing the entire text of a CSV `String`
    ///
    /// This is a simple wrapper that takes the result of `allAsCSV(withPrefix:)` and renders it as bytes.
    ///   - parameter prefix: A fragment of CSV that will be added to the front of each record. Any trailing comma at the end will be omitted. _See_ the note at ``TimedWalkObserver/marshalledRecords(withPrefix:)``
    func allAsTaggedData() -> Data {
        let content = allTaggedCSV()
        guard let data = content.data(using: .utf8) else { fatalError("Could not derive Data from the CSV string") }
        return data
    }

    // MARK: Writing

    func addToArchive() throws {
        // TODO: Throwing
        let data = allAsTaggedData()
        try CSVArchiver.shared
            .addToArchive(data: data, forPhase: phase)
    }

    /// Write all CSV records into a file.
    /// - Parameters:
    ///   - prefix: A fragment of CSV that will be added to the front of each record. Any trailing comma at the end will be omitted. _See_ the note at ``marshalledRecords(withPrefix:)``
    ///   - url: The location of the new file.
    func write(phase: WalkingState, to url: URL) throws {
        // TODO: Make it async
        let fm = FileManager.default
        let data = allAsTaggedData()
        try fm.deleteAndCreate(at: url, contents: data)
//        Self.registerFilePath(url.path)
    }

    /// Marshall all the `CMAccelerometerData` data and write it out to a named file in the Documents directory.
    /// - Parameters:
    ///   - fileName: The base name of the target file as a `String`. No extension will be added.
    ///   - prefix: A fragment of CSV that will be added to the front of each record. Any trailing comma at the end will be omitted. _See_ the note at ``marshalledRecords(withPrefix:)``
    func writeToFile(named fileName: String,
                     phase: WalkingState) throws {
        precondition(!fileName.isEmpty,
                     "\(#function): empty prefix string")
        let destURL = try FileManager.default
            .docsDirectory(create: true)
            .appendingPathComponent(fileName)
            .appendingPathExtension("csv")

        try write(phase: phase, to: destURL)
    }

    // FIXME: - URGENT - get a way to have a global subject ID.
    static var lastData = try! CSVArchiver()

    func outputBaseName(walkState: WalkingState) -> String {
        let isoDate = Date().iso
        let state = walkState.csvPrefix
        // Force-unwrap: The phase _will_ be .walk_N, which _will_ have a prefix.
        return "Sample-\(state!):\(isoDate)"
    }

//    func writeToFile(walkState: WalkingState) throws {
//        precondition(walkState == .walk_2 || walkState == .walk_1,
//                     "Unexpected walk state \(walkState)"
//        )
//        let baseName = outputBaseName(walkState: walkState)
//        try writeToFile(
//            named: baseName,
//            linesPrefixedWith: "\(walkState.csvPrefix!),Sample")
//    }

}
