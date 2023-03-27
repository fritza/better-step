//
//  IncomingAccelerometry+Marshalling.swift
//  Better Step
//
//  Created by Fritz Anderson on 10/4/22.
//

import Foundation

extension IncomingAccelerometry {
    private func marshalledRecords(tag: SeriesTag) -> [String] {
        assert(SubjectID.isSet)
        let common = "\(tag.rawValue),\(SubjectID.id),"
        let all = self.all()
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
}
