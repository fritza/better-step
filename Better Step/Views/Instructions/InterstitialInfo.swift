//
//  InterstitialInfo.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/9/22.
//

import Foundation

/**
 ## Topics

 ### Properties
 - `id`
 - `intro`
 - `proceedTitle`
 - `pageTitle`
 - `systemImage`

 ### Initialization
 - `init(id:intro:proceedTitle:pageTitle:systemImage:)`
 - `init(_:id:)`
 */
/// An element of ``InterstitialList``, providing common types of content for an interstitial view.
///
/// The expected use decodes `InterstitialInfo` from a JSON file. It is _not_ possible to initialize one directly.
struct InterstitialInfo: Codable, Hashable, Identifiable, CustomStringConvertible {
    /// Ths ID for this page, automatically assigned, and **one-based**.
    public let id: Int
    /// The introductory text for the page, above the icon.
    public let introAbove: String
    /// The introductory text for the page, below the icon.
    public let introBelow: String
    // FIXME: Shouldn't have just one text area.
    /// The label on the regular "proceed" `Button` at bottom.
    public let proceedTitle: String
    public let pageTitle: String
    /// The SF Symbols name for the image to display in the middle of the page.
    public let systemImage: String?

    /// Element-wise initialization.
    ///
    /// `InterstitialInfo` should have no public initializers, but this one has to be exposed for previewing.
    internal init(id: Int,
                  introAbove: String, introBelow: String, proceedTitle: String, pageTitle: String, systemImage: String?) {
        self.id = id
        self.introAbove = introAbove
        self.introBelow = introBelow
        self.proceedTitle = proceedTitle
        self.pageTitle = pageTitle
        self.systemImage = systemImage
    }

    /// Initialize an `InterstitialInfo` from its `Decodable` content, plus an `Int` ID supplied by ``InterstitialList``.
    ///
    /// `InterstitialInfo` has no public initializers.
    /// - Parameters:
    ///   - stub: The `Decodable` (``TaskInterstitialDecodable``) content for the interstitial page.
    ///   - id: The ID assigned from an `InterstitialList`
    fileprivate init(_ stub: TaskInterstitialDecodable,
                     id: Int) {
        self.init(
            id: id,
            introAbove: stub.introAbove.addControlCharacters,
            introBelow: stub.introBelow.addControlCharacters,
            proceedTitle: stub.proceedTitle,
            pageTitle: stub.pageTitle,
            systemImage: stub.systemImage)
    }

    var description: String {
        "IntersitialInfo id \(id) “\(pageTitle)”"
    }
}

/**
 ## Topics

 ### Properties
 - `intro`
 - `proceedTitle`
 - `pageTitle`
 - `systemImage`

 ### Decoding
 - `unescaped`
 */

/// Decodable content for the page _except_ for the ID, which is assigned at decoding time as JSON array order **plus one**.
///
/// See ``InterstitialInfo`` for details on the properties.
struct TaskInterstitialDecodable: Codable {
    let introAbove: String
    let introBelow: String
    // TODO: Should proceedTitle ever be nil?
    let proceedTitle: String
    let pageTitle: String
    let systemImage: String?

    // TODO: See if this is ever needed.
    var unescaped: TaskInterstitialDecodable {
        return TaskInterstitialDecodable(
            introAbove: self.introAbove.addControlCharacters,
            introBelow: self.introBelow.addControlCharacters,
                                         proceedTitle: proceedTitle,
                                         pageTitle: pageTitle,
                                         systemImage: systemImage)
    }
}

/**
## Topics

 ### Properties
 - `decoder`
 - `baseName`
 - `interstitials`
 - `decoder`
 - `paseName`

 ### Indexing
 - `item(forID:)`

 ### Initialization
 - `init(baseName:)`

 ### Collection
 - `startIndex`
 - `endIndex`
 - `subscript(index:)`

 ## CustomStringConvertible
 - `description`
 */
/// An indexed collection of ``InterstitialInfo`` (static description of an interstitial page) as read from a JSON file.
///
/// This is expected to be the content of all interstitials within a task. Clients are responsible for matching indices to the needs of a particular interstitial.
///
/// `InterstitialList` is initialized from a JSON file, given the file's basename. The JSON must not attempt to specify IDs; this will be done at init time.
/// - note: All methods expect a 1-based index.
struct InterstitialList: Codable, CustomStringConvertible {
    typealias Element = InterstitialInfo
    typealias Index   = Int

    // Coding
    enum CodingKeys: String, CodingKey {
        case baseName, interstitials
    }
    private static let decoder = JSONDecoder()

    private let baseName: String
    private let interstitials: [InterstitialInfo]

    /// The `InterstitialInfo`, if any, having the supplied ID.
    /// - note: This is an _ID,_ not the collection index used for subscripting.
    /// - parameter target: The ID to search for.
    /// - returns: `InterstitialInfo` for the element with that ID, or `nil` if there is none.
    func item(forID target: Int) -> InterstitialInfo? {
        let retval = interstitials
            .first(where: { $0.id == target } )
        return retval
    }

    /// Load the list of `InterstitialInfo` from a (base)named `Bundle` file.
    ///
    /// Elements in the file will not specify IDs; they identify by their order in the `json` file. This initializer assigns each an `id`  of file order + 1.
    /// - Parameter baseName: The base name of the file to decode, e.g. `mumble` for `mumble.json`.  The source file must have the `json` extension.
    init(baseName: String) throws {
        // TODO: init should throw, probably.
        //       Actually no, failing to get a content file should be fatal.
        self.baseName = baseName
        // Fill in the interstital list, if any
        guard let url = Bundle.main.url(forResource: baseName, withExtension: "json") else { throw DASIReportErrors.couldntCreateDASIFile}
        let jsonData = try Data(contentsOf: url)
        let rawList = try Self.decoder
            .decode([TaskInterstitialDecodable].self,
                    from: jsonData)
        let idedList = rawList.enumerated()
            .map { (idNum, content) in
                return InterstitialInfo(content, id: idNum+1)
            }
        interstitials = idedList
//        else {
//            interstitials = []
//        }
    }

    // MARK: CustomStringConvertible adoption
    public var description: String {
        let base = "InterstitialList (\(interstitials.count)) from \(baseName).json:\n"
        let list = interstitials.map(\.description)
            .joined(separator: "\n\t")
        return base + list
    }
}

// - MARK: RandomAccessCollection adoption
extension InterstitialList: RandomAccessCollection {
    var startIndex: Int { 1 }
    var endIndex: Int { interstitials.count + 1 }
    subscript(index: Int) -> Element { interstitials[index-1] }
}
