//
//  Configuration.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/14/22.
//

import SwiftUI
import MessageUI

struct Accelerometry: Decodable {
    @AppStorage("walkDuration") var durationInMinutes = 6

//    static let walkDurationSecondsKey = "walk duration"

    let frequency: Double
    let instructionAvailable: String
    let instructionNotAvailable: String

    enum CodingKeys: String, CodingKey {
        case frequency, instructionAvailable, instructionNotAvailable
    }

    func instruction(available: Bool) -> String {
        let workingString = (available ?
        instructionAvailable : instructionNotAvailable) as NSString
        let retval = workingString
            .replacingOccurrences(of: "$MIN$",
                                  with: durationInSeconds.spelled)
        return retval
    }

    /// Ignored in favor of the default keyed `walkDurationSecondsKey`
    //        let duration: Double
    @available(*, unavailable, renamed: "durationInSeconds")
    var duration: Double { fatalError("replaced duration with durationInSeconds") }

    /// Duration of the walk **IN SECONDS**.
    var durationInSeconds: Double {
        assert((1...10).contains(durationInMinutes))
        let durationInSeconds = 60 * durationInMinutes
        return Double(durationInSeconds)
    }
}


/// Value embodiment of the settings in `config-mini.plist`.
///
/// Do not instantiate `Configuration` yourself. Access settings through `Configuration.shared`, which will load the data if needed.
struct Configuration: Decodable {
    // MARK: Singleton
    private static var _shared: Configuration?
    private static let configBaseName = "config-mini"

    let resultStrings: [String]!
    let mailing: [String:String]!
    let mailResults: [[String:String]]!

    let accelerometer: Accelerometry!

    private static func loadConfiguration() -> Configuration {
        let decoder = PropertyListDecoder()
        guard
            let url = Bundle.main.url(forResource: configBaseName, withExtension: "plist"),
            let data = try? Data(contentsOf: url)
            else {
                fatalError("\(#function) - plist or content not available")
        }
        do {
            let retval = try decoder
                .decode(Configuration.self, from: data)
            _shared = retval
            return retval
        }
        catch {
            print(#function, "- Could not decode the configuration file:", error)
            fatalError()
        }
    }

    // MARK: - Mini (mailing)

//    struct MailResult: Decodable {
//        let title:  String
//        let text:   String
//    }

    // MARK: Mini (Mail results)
//    let mailing: Mailing
//    let mailResults: [MailResult]
}

import Messages
final class Mailing: Decodable {
    @AppStorage("emailAddress")
    var recipientEmail: String = "NOBODY@EXAMPLE.COM"
    var subject: String = ""
    var body: String = ""

    enum CodingKeys: String, CodingKey {
        case subject, body
    }

    /// Fill the subject, recipient, and body of a mail composer
    /// - note: Clients are expected to add attachments themselves.
    ///
    /// - Parameters:
    ///   - mailer: The mail composet to receive `recipient`, `subject`, and `body`.
    ///   - subjectID: The study identifier for the subject.
    func complete(_ mailer: MFMailComposeViewController,
                  for subjectID: String) {
        mailer.setSubject(subject.replacingOccurrences(
            of: "%subjectID%", with: subjectID))
        mailer.setToRecipients([recipientEmail])
//        mailer.setToRecipients([Defaults.recipientEmail.value() ?? "NOBODY@EXAMPLE.COM"])
        mailer.setMessageBody(self.body(
            for: subjectID), isHTML: false)
    }

    /// The body of a forwarding message about a study participant.
    ///
    /// - Parameter subjectID: The ID assigned by the study to the patient.
    /// - Returns: The text for the body of the message.
    private func body(for subjectID: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        let now = dateFormatter.string(from: Date())

        let template = body
            .replacingOccurrences(of: "%subjectID%", with: subjectID)
            .replacingOccurrences(of: "%currentDate%", with: now)

        return template
    }
}
