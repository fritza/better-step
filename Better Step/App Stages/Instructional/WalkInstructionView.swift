//
//  WalkInstructionView.swift
//  Better Step
//
//  Created by Fritz Anderson on 4/6/22.
//

import SwiftUI

enum ResourceErrors: Error {
    case urlNotValid(URL?)
    case directoryNotFound(URL?)
    case imageFileNotFound(String)
    case couldNotDecodeSettings
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
        do {
            let plURL = ShortWalkSettings.plistURL

            guard let plURL = plURL else { throw ResourceErrors.urlNotValid(plURL)
            }
            settings = try ShortWalkSettings.settings()
            relativeBaseURL = plURL.deletingLastPathComponent()
            imageURLsByName = Self._imageURLsByName()
        }
        catch {
            settings = ShortWalkSettings(
                title: "URL Error",
                mdContent: "The **Settings** could not be found in the **Resources** directory. (\(error))")
            relativeBaseURL = URL(fileURLWithPath: "")
            imageURLsByName = [:]
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
