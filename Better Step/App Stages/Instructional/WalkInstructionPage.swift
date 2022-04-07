//
//  WalkInstructionPage.swift
//  Async Accel
//
//  Created by Fritz Anderson on 4/7/22.
//

import Foundation
import SwiftUI
import Collections

/*
 Look, all we need is some Markdown, we can leave the images, I think, to img links inline.

 There is still the problem of fonts and sizes, so things like titles and body text have to be specified separately by role.

 So you have to provide an array of role/markdown pairs. It'd be _nice_ to reduce that to `Array<TextElement>`, where `TextElement` is an enum describing roles and content.
 */

enum TextElement: Equatable, Hashable {
    case title(text: String)
    case image(key : String)
    case body(content: AttributedString)
    case unknown(source: String)

    init(roleAndContent pair: [String]) {
        precondition(pair.count == 2)
        switch (pair[0], pair[1]) {
        case ("title", let content): self = .title(text: content)
        case ("image", let key): self = .image(key: key)
        case ("body" , let content):
            if let attributed = try? AttributedString(markdown: content) {
                self  = .body(content: attributed)
            }
            else {
                self = .unknown(source: content)
            }

        default: fatalError("Unknown tag “\(pair[0])”")
        }
    }

    var id: Int { self.hashValue }

    @ViewBuilder
    var rendering: some View {
        switch self {
        case .title(let text)     : Text(text)   .font(.title)
        case .body (let content)  : Text(content).font(.body)
        case .image(let key)      : Image(key)
        case .unknown(let source) : Text("Could not parse Markdown source “\(source)”")
                .fontWeight(.bold)
        }
    }

    static func elements(from source: Data) -> [TextElement] {
        // At least "a\nb"
        do {
            guard let strs = String(data: source, encoding: .utf8)?
                .split(separator: "\n"),
                  strs.count % 2 == 0
            else { return [] }

            var retval: [TextElement] = []
            for index0 in stride(from: 0, to: strs.count, by: 2) {
                let (type, value) = (String(strs[index0]), String(strs[index0 + 1]))
                let element = TextElement(roleAndContent: [type, value])
                retval.append(element)
            }
            return retval
        }
    }

    static func elements(from url: URL) throws -> [TextElement] {
        let data = try Data(contentsOf: url)
        return elements(from: data)
    }

    static func elements(fromDirectoryNamed name: String,
                         baseName: String, `extension`: String = "txt",
                         subdirectory: String?) throws -> [[TextElement]] {
        guard let urls = Bundle.main.urls(forResourcesWithExtension: `extension`,
                                          subdirectory: subdirectory) else { return [] }
        let dataPerFile = urls
            .map { url in
                (url.lastPathComponent, url)
            }
            .sorted { (lhs, rhs) -> Bool in lhs.0 < rhs.0 }

        let retval = dataPerFile.compactMap { try? elements(from: $0.1) }
        return retval
    }
}



struct WalkInstructionPage: Decodable, Identifiable, Hashable {
    static let plistBasename = "ShortWalk"
    static let resourceDirName: String? = "WalkResources"

    var id: Int {
        [title, mdContent].hashValue
    }
    let title: String
    let mdContent: String

    init(title: String, mdContent: String) {
        (self.title, self.mdContent) = (title, mdContent)
    }
}

extension WalkInstructionPage {
    private static let plistURL = Bundle.main.url(
        forResource: plistBasename,
        withExtension: "plist",
        subdirectory: resourceDirName)

    static func pages() throws -> [WalkInstructionPage] {
        let plistData = try Data(contentsOf: plistURL!)
        return try PropertyListDecoder()
            .decode([WalkInstructionPage].self, from: plistData)
    }
}
