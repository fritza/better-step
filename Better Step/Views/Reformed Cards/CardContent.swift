//
//  CardContent.swift
//  Gallery
//
//  Created by Fritz Anderson on 3/14/23.
//

import Foundation

// MARK: - CardContent
struct CardContent: Decodable, Identifiable, Hashable {
    static let decoder = JSONDecoder()
    public static let errorDomain = "CardContentDomain"
    
    enum ImageSource {
        case systemName, fileName, neither, both
        var valid: Bool { self == .fileName || self == .systemName }
        init(system: String?, file: String?) {
            switch (system != nil, file != nil) {
            case (true, true)   : self   = .both
            case (false, false) : self = .neither
            case (true, false)  :  self = .systemName
            case (false, true)  : self = .fileName
            }
        }
    }
    
    // MARK: Properties
    public let pageTitle, contentBelow, contentAbove, proceedTitle: String
    public let systemImage, imageAssetName: String?
    
    public var id: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case pageTitle
        case contentBelow
        case contentAbove
        case systemImage
        case imageAssetName
        case proceedTitle
    }
    
    // MARK: Memberwise
    public init(pageTitle: String, contentBelow: String, contentAbove: String, systemImage: String?, imageFileName: String?, proceedTitle: String) {
        self.pageTitle      = pageTitle
        self.contentBelow   = contentBelow
        self.contentAbove   = contentAbove
        self.systemImage    = systemImage
        self.imageAssetName  = imageFileName
        self.proceedTitle   = proceedTitle
    }

    // MARK: - CardContent loading
    
    
    /// Produce an array of ``CardContent`` from a `.json` containing an _array_ of objects.
    ///
    /// Not to be confused with  ``contentArray(from:)-4uucs`` (reads a singleton) or ``createOneContent(from:)`` (read   ``contentArray(from:)-8171j`` (attempts to read as singleton _or_ array).
    ///- note: ``CardContent`` has a number of statics that derive arrays from
    ///        singleton or array JSON, array of JSON basenames, or by trying to decode
    ///        as singleton or multiple, whichever works. See the class documentation for the
    ///        combinations.

    /// - Parameter basename: The base name of the `.json` file to decode.
    /// - Returns: Single-element array of ``CardContent`` derived from the file.
    /// - throws: A Foundation error arising from failure to decode the file contents; or ``CardErrorCodes`` if no content could be found.
    public static func createContents(from baseName: String) throws -> [CardContent] {
        guard let url = Bundle.main.url(forResource: baseName, withExtension: "json") else {
            throw CardErrorCodes.noURL(baseName).nsError()
        }
        
        let data: Data
        do { data = try Data(contentsOf: url) }
        catch {
            throw CardErrorCodes.noData(baseName).nsError()
        }
        let retval: [CardContent]
        do { retval = try Self.decoder.decode([CardContent].self, from: data) }
        catch {
            throw CardErrorCodes.notDecoded(error).nsError()
        }
        
        assert(!retval.isEmpty)
        return retval
    }
    
    /// Produce an array of ``CardContent`` from a `.json` containing a _single_ object.
    ///
    /// Not to be confused with ``createContents(from:)`` (reads an array from one file) or
    ///  ``contentArray(from:)-4uucs`` (reads a singleton) or ``contentArray(from:)-8171j``
    ///  (builds an array from an array of base names)).

    ///- note: ``CardContent`` has a number of statics that derive arrays from
    ///        singleton or array JSON, array of JSON basenames, or by trying to decode
    ///        as singleton or multiple, whichever works. See the class documentation for the
    ///        combinations.
    /// - Parameter basename: The base name of the `.json` file to decode.
    /// - Returns: Single-element array of ``CardContent`` derived from the file.
    /// - throws: A Foundation error arising from failure to decode the file contents; or ``CardErrorCodes`` if no content could be found.
    public static func createOneContent(from baseName: String) throws -> [CardContent] {
        guard let url = Bundle.main.url(forResource: baseName, withExtension: "json") else {
            throw CardErrorCodes.noURL(baseName).nsError()
        }
        
        let data: Data
        do { data = try Data(contentsOf: url) }
        catch {
            throw CardErrorCodes.noData(baseName).nsError()
        }
        let retval: CardContent
        do {
            retval = try Self.decoder.decode(CardContent.self, from: data)
            assert(ImageSource(
                system: retval.systemImage,
                file: retval.imageAssetName).valid,
            "Neither or both image sources are set")
        }
        catch {
            throw error
        }
        return [retval]
    }
    
    /// Produce an array of ``CardContent`` from JSON in a file.
    ///
    /// The file may contain a single content object, or an array of them. This function will try both.
    ///
    /// Not to be confused with ``createContents(from:)`` (reads an array) or ``contentArray(from:)-4uucs`` (reads a singleton) or ``createOneContent(from:)``
    ///- note: ``CardContent`` has a number of statics that derive arrays from
    ///        singleton or array JSON, array of JSON basenames, or by trying to decode
    ///        as singleton or multiple, whichever works. See the class documentation for the
    ///        combinations.

    /// - Parameter basename: The base name of the `.json` file to decode.
    /// - Returns: Array of ``CardContent`` derived from the file.
    /// - throws: A Foundation error arising from failure to decode the file contents.
    public static func contentArray(from basename: String) throws -> [CardContent] {
        let retval: [CardContent]
        do {
            retval = try createContents(from: basename)
        }
        catch {
            do {
                retval = try createOneContent(from: basename)
            }
            catch {
                throw error
            }
        }
        return retval
    }
    
    /// Derive a single array of ``CardContent`` from an array of JSON basenames.
    /// The contents of the files may be singletons or arrays.
    ///
    /// ``CardContent`` has a number of statics that derive arrays from
    ///        singleton or array JSON, array of JSON basenames, or by trying to decode
    ///        as singleton or multiple, whichever works. See the class documentation for the
    ///        combinations.
    /// - Parameter names: The basenames of the files to be decoded
    /// - Returns: An array of ``CardContent`` resulting from decoding the files.
    /// - throws: Foundation file errors, or coding errors out of ``CardErrorCodes``
    public static func contentArray(
        from names: [String]) throws -> [CardContent] {
        let retval = try names.flatMap { name in
            let array = try contentArray(from: name)
            return array
        }
            return retval.setIDs()
    }
}

extension Array where Element == CardContent {
    /// Set the `id`s in an array of ``CardContent`` to consecutive integers.
    /// - returns: A new `Array` with the same contents as `self` but for the re-initialized `id`s
    func setIDs() -> [CardContent] {
        let retval = self
            .reduce([CardContent]()) { arraySoFar, cardContent in
                var content = cardContent
                content.id = arraySoFar.count
                return arraySoFar + [content]
            }
        
        assert(retval.cardsAreValid)
        
        return retval
    }
    
    var hasCorrectIDs: Bool {
        self.enumerated().allSatisfy { n, record in
            n == record.id
        }
    }
    
    var areDistinct: Bool {
        let stringPaths: [KeyPath<CardContent, String>] = [
            \.pageTitle, \.contentBelow, \.contentAbove, \.proceedTitle,
        ]
        var strings: Set<String> = []
        for card in self {
            let crude = stringPaths.reduce("") { partialResult, path in
                return partialResult + card[keyPath: path]
            }
            if strings.contains(crude) {
                return false
            }
            strings.insert(crude)
        }
        return true
    }
    
    var cardsAreValid: Bool {
        hasCorrectIDs && areDistinct
    }
    
}
