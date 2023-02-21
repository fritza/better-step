//
//  DataDestruction.swift
//  Better Step
//
//  Created by Fritz Anderson on 10/20/22.
//

import Foundation

let GoodUploadNotice = Notification.Name("good upload")
let CleanUpPhases = Notification.Name("clean up phases")
// Are the two any different?
// A recipient of the good-upload can recognize completion of first run.

let SessionCompletedNotce = Notification.Name("Session Complete")
// That's the same as good upload, right?

let ForceAppReversion = Notification.Name("Drop all data")
let ResetSubjectIDNotice = Notification.Name("reset SubjectID")
