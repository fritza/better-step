//
//  InstructionElement.swift
//  Better Step
//
//  Created by Fritz Anderson on 4/7/22.
//

import Foundation
import SwiftUI

/**
 Enumeration that describes “paragraphs” for on-screen documentation.

 So far, the elements are
 - `title`: `.title`-styled text, expected to be used at the top of the view.
 - `body`:  `.body`-styled text, initialized from Markdown source
 - `image`: An image from the app resources to be displayed after the preceding paragraph.
 - `unknown`: Shouldn't happen. It indicates a fault in parsing the Markdown provided for a `body`.

 You compose an instruction page typically by providing a newline-delimited text file. The even lines (counting from zero) are tags, the odd lines are content. Each pair describes a “paragraph.”

 **Example**
```
 title
 Welcome!
 body
 We're _so_ glad you're joining us in developing a new tool for patients to share cardiac health information with their caregivers, right in their own homes.
```
 */
enum InstructionElement: Hashable, CustomStringConvertible, Identifiable {
    /// Title text -> `Text`
    case title(text: String)
    /// Image file name -> `Image`
    case image(key : String)
    /// Body text, to be interpreted as Markdown source
    case body(content: AttributedString)
    /// Exceptional: The Markdown parse failed.
    case unknown(source: String)

    var description: String {
        switch self {
        case .title(let text)     : return "title(\(text))"
        case .body (let content)  : return
            "body(\((String(content.characters))))"
        case .image(let key)      : return "image(\(key))"
        case .unknown(let source) : return "? unknown(\(source))"
        }
    }


    /// Create an `InstructionElement` from a pair of `String`s.
    /// - precondition: It is fatal for `pair.count` to be other than 2.
    /// - Parameter pair: An Array of exactly two `String`s, the first element being the paragraph type, the second its content.
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

    /// A SwiftUI `View` that renders the element.
    @ViewBuilder
    var rendering: some View {
        switch self {
        case .title(let text)     : Text(text)   .font(.title)
        case .body (let content)  : Text(content).font(.body)
        case .image(let key)      :
            if let uiImage =
//                UIImage( named: key, in: Bundle.main, with: nil)
            UIImage(named: key)
            {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .shadow(radius: 2.0)
            }
            else { Color.green }
        case .unknown(let source) : Text("Could not parse Markdown source “\(source)”")
                .fontWeight(.bold)
        }
    }

    /// Decode a newline-delimited `String` from the given `Data` and render each pair of lines as `InstructionElement`s
    /// - Parameter source: The `Data`, typically file content in which pairs of lines identify an element tag and its contents
    /// - Returns: An `Array` of `InstructionElement` derived from each pair. Any errors (such as failure to decode or an odd number of lines) terminate the function and returns `[]`.
    static func elements(from source: Data) -> [InstructionElement] {
        // At least "a\nb"
        let asString = String(data: source, encoding: .utf8)
        let asLines = asString!.split(separator: "\n")
        print("lines:", asLines)
        print(asLines.count)

        guard let strs = String(data: source, encoding: .utf8)?
            .split(separator: "\n"),
              strs.count % 2 == 0
        else { return [] }

        var retval: [InstructionElement] = []
        for index0 in stride(from: 0, to: strs.count, by: 2) {
            let (type, value) = (String(strs[index0]), String(strs[index0 + 1]))
            let element = InstructionElement(roleAndContent: [type, value])
            retval.append(element)
        }
        return retval
    }

    /// Decode a newline-delimited `String` from `Data` loaded from a file identified by URL, and render each pair of lines as `InstructionElement`s. Once the file is read, the contents are passed on to `elements(from:Data)`, which see.
    /// - parameter url: The URL for the file to be read and converted.
    static func elements(from url: URL) throws -> [InstructionElement] {
        let data = try Data(contentsOf: url)
        return elements(from: data)
    }

    /// Find a newliine-delimited file in `Bundle.main` identified by base name, extension, and possibly the bundle subdirectory in which it is to be found. Load the data Decode a newline-delimited `String` from `Data` loaded from a file identified by URL, and render each pair of lines as `InstructionElement`s. Once the file is read, the contents are passed on to `elements(from:Data)`, which see.
    /// Scan the contents of a bundle directory for files that are formatted as `InstructionElement`s, attempt to convert each to arrays of `InstructionElement`, and return those that succeeded.
    /// - parameter `extension`: The scan will be limited to files with this extension. Defaults to `txt`.
    /// - parameter subdirectory: The name of the subdirectory in the main bundle to be searched. By default the bundle's resource directory is searched.
    /// - Returns: An array, of which each member is an `Array<InstructionElement>` from a source file. The returned array is ordered by the names of the source files.
    /// -note: The result array will be one per source file, and in order by file name, but the file name is not preserved. The expected use is to populate a list of pages in order and index through them; whatever navigates through them should be agnostic as to the content of pages.
    static func elements(withExtension `extension`: String = "txt",
                         subdirectory: String? = nil) throws -> [[InstructionElement]] {
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

