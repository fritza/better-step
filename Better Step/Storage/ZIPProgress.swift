//
//  ZIPProgress.swift
//  Better Step
//
//  Created by Fritz Anderson on 10/5/22.
//

import Foundation


// Whew. A notification.
/// `Notification` that a CSV file has been created and saved.
let ZIPDataWriteCompletion = Notification.Name(rawValue: "zipDataWriteCompletion")

/// `Notification` that a CSV file has been inserted into the `Archive`.
let ZIPDataArchiveCompletion = Notification.Name(rawValue: "zipDataArchiveCompletion")

// Attempt to write a task csv failed.
let SeriesWriteFailed = Notification.Name(rawValue: "SeriesWriteFailed")
// Attempt to write a task csv failed.
let SeriesWriteSucceeded = Notification.Name(rawValue: "SeriesWriteSucceeded")

enum ZIPProgressKeys: String {
    /// `nil` or the `Error` result .
    case error
    /// The phase (`WalkingPhase`) for the walking phase saved/archived
    case phase
    /// The `URL` of the saved/archived  `.csv` file.
    case fileURL

    static func dictionary(error: Error) -> [ZIPProgressKeys:Any] {
        return [ZIPProgressKeys.error: error]
    }

    static func dictionary(phase: SeriesTag, url: URL) -> [ZIPProgressKeys:Any] {
        return [ZIPProgressKeys.error: error,
                ZIPProgressKeys.phase: phase,

                ZIPProgressKeys.fileURL: url]
    }
}
