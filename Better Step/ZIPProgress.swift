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

enum ZIPProgressKeys: String {
    /// `nil` or the `Error` result .
    case error
    /// The phase (`WalkingPhase`) for the walking phase saved/archived
    case phase
    /// The `URL` of the saved/archived  `.csv` file.
    case fileURL

    static func reading(_ dict: [ZIPProgressKeys: Any],
                        error: inout Error?,
                        phase: inout WalkingState?,
                        fileURL: inout URL?) {
        (error, phase, fileURL) = (nil, nil, nil)
        if let e = dict[.error] as? Error {
            error = e; return
        }
        let csvPrefix = dict[.phase] as! String
        phase = WalkingState(rawValue: csvPrefix)!
        fileURL = dict[.fileURL] as? URL
    }

    static func dictionary(error: Error) -> [ZIPProgressKeys:Any] {
        return [ZIPProgressKeys.error: error]
    }

    static func dictionary(phase: WalkingState, url: URL) -> [ZIPProgressKeys:Any] {
        return [ZIPProgressKeys.error: error,
                ZIPProgressKeys.phase: phase.csvPrefix!,
                ZIPProgressKeys.fileURL: url]
    }
}
