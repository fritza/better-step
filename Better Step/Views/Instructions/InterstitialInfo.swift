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

    public let pageTitle: String?
    /// The introductory text for the page, above the icon.
    public let contentAbove: String?
    /// The introductory text for the page, below the icon.

    /// The SF Symbols name for the image to display in the middle of the page.
    /// - note: At most one of `systemImage` and `assetImage` may be `nil`.
    public let systemImage: String?
    /// The asset name for the image to display in the middle of the page.
    /// - note: At most one of `systemImage` and `assetImage` may be `nil`.
    public let assetImage : String?
    
    /// The text to be shown below the icon.
    public let contentBelow: String?
    /// The label on the regular "proceed" `Button` at bottom.
    public let proceedTitle: String?
    

    /// Element-wise initialization.
    ///
    /// `InterstitialInfo` should have no public initializers, but this one has to be exposed for previewing.
    internal init(id: Int,
                  pageTitle: String? = nil,
                  contentAbove: String? = nil,
                  
                  systemImage: String? = nil,
                  assetImage : String? = nil,
                  
                  contentBelow: String? = nil,
                  proceedTitle: String? = nil) {
        self.id = id
        self.contentAbove = contentAbove
        self.systemImage = systemImage
        self.assetImage = assetImage
        self.contentBelow = contentBelow
        self.pageTitle = pageTitle
        self.proceedTitle = proceedTitle
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
            pageTitle: stub.pageTitle,
            contentAbove: stub.contentAbove?.addControlCharacters,
            
            systemImage: stub.systemImage,
            assetImage: stub.assetImage,
            
            contentBelow: stub.contentBelow?.addControlCharacters,
            proceedTitle: stub.proceedTitle
        )
    }

    var description: String {
        "IntersitialInfo id \(id) “\(pageTitle ?? "<n/a>")"
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
    let pageTitle: String?
    let contentAbove: String?
    
    let systemImage: String?
    let assetImage: String?
    
    let contentBelow: String?
    // TODO: Should proceedTitle ever be nil?
    let proceedTitle: String?

    // TODO: See if this is ever needed.
    var unescaped: TaskInterstitialDecodable {
        let aboveString = self.contentAbove?.addControlCharacters
        let belowString = self.contentBelow?.addControlCharacters
        
        return TaskInterstitialDecodable(
            pageTitle: self.pageTitle,
            contentAbove: aboveString,

            systemImage: systemImage,
            assetImage: assetImage,

            contentBelow: belowString,
            proceedTitle: proceedTitle)
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

    var indexRange: ClosedRange<Int> {
        let lower = interstitials.map(\.id).min()!
        let upper = interstitials.map(\.id).max()!
        return lower...upper
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
    var collectionEndIndex: Int { interstitials.count }
    subscript(index: Int) -> Element { interstitials[index-1] }
}
