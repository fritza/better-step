//
//  AppStorageKeys.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/28/22.
//

import Foundation

// MARK: - @AppStorage
enum AppStorageKeys: String {
    /// How long the timed walk is to last, in _minutes,_ e.g. 6.
    case walkInMinutes
    /// The frequency in Hertz (e.g. 120) for sampling the accelerometer.
    case walkSamplingRate
    /// If `false`, report acceleration in three axes; otherwise as the vector magnitude.
    case reportAsMagnitude
    /// The email address to receive report archive files.
    case reportingEmail
    /// Whether to include the timed walk
    case includeWalk
    /// Whether to include a second timed walk
    case includeSecondWalk
    /// Whether to include the DASI survey
    case includeDASISurvey
    /// Whether to include the usability survey
    case includeUsabilitySurvey
    /// The last known subject ID.
    case subjectID

    /// Completion of the "post-usability" task.
//    case usability

    /// The raw value for the completed stages.
    case completedStages

    static let dasiWalkRange = (1...10)
}
