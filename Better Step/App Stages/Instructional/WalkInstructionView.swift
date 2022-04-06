//
//  WalkInstructionView.swift
//  Better Step
//
//  Created by Fritz Anderson on 4/6/22.
//

import SwiftUI

enum ResourceErrors: Error {
    case urlNotValid
    case directoryNotFound
    case imageFileNotFound(String)
    case couldNotDecodeSettings
}

struct ShortWalkSettings: Codable, Identifiable, Hashable {
    static let plistBasename = "ShortWalk"
    static let resourceDirName = "Resources"

    let id: Int
    let title: String
    let mdContent: String

    static let plistURL = Bundle.main.url(forResource: plistBasename, withExtension: "plist", subdirectory: resourceDirName)

    init(title: String, mdContent: String) {
        (self.title, self.mdContent) = (title, mdContent)
        id = [title, mdContent].hashValue
    }

    static func settings() throws -> ShortWalkSettings {
        let plistData = try Data(contentsOf: plistURL!)
        return try PropertyListDecoder()
            .decode(ShortWalkSettings.self, from: plistData)
    }
}

struct WalkInstructionView: View {
//    let plistURL: URL
    let settings        : ShortWalkSettings
    static let imageNames = ["hero", "tabBar"]
    let imageURLsByName : [String:URL]
    let bodyContent     : AttributedString

    init() {
        // Should be throws instead of failable?
        let relativeBaseURL: URL
        if let plfLocal = ShortWalkSettings.plistURL {
            settings  = try! ShortWalkSettings.settings()
            imageURLsByName = Self._imageURLsByName()
            relativeBaseURL = plfLocal.deletingLastPathComponent()
        }
        else {
            settings = ShortWalkSettings(title: "URL Error",
                                         mdContent: "The **Settings** could not be found in the **Resources** directory.")
            imageURLsByName = [:]
            relativeBaseURL = URL(fileURLWithPath: "")
        }
        bodyContent = try! AttributedString(
            markdown: settings.mdContent,
            baseURL: relativeBaseURL)
    }

    var body: some View {
        VStack {
            Text(settings.title)
            Spacer()
            Text(bodyContent)
        }
    }
}

extension WalkInstructionView {
    // MARK: - URL helpers

    static func _imageURLsByName() -> [String:URL] {
        let nameKeyedURLs = imageNames
            .map {
                ($0,
                 Bundle.main
                    .url(forResource: $0, withExtension: "jpg", subdirectory: "Resources")
                )
            }
            .filter { $0.1 != nil }
            .map { ($0.0, $0.1!) }

        let retval = Dictionary(uniqueKeysWithValues: nameKeyedURLs)
        return retval
    }
}

struct WalkInstructionView_Previews: PreviewProvider {
    static var previews: some View {
        WalkInstructionView()
    }
}
