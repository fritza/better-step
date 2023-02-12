import Foundation

/// Constructor for simple `Error`s carrying URL strings or freehand `String`s, or neither, in `userInfo`
public enum SimpleErrors: Error {
    ///
    case strError(String)
    case urlError(URL)
    case nosError
    
    public init(_ datum: String) { self = .strError(datum) }
    public init(_ datum: URL) { self = .urlError(datum) }
    public init() { self = .nosError }
    public static let domain = "SimpleErrors"
    
    /// An `NSError` (erased to `Error`) reporting a condition identified in `userInfo` as "`condition`"
    public var error: Error {
        /// `Error` code
        let code: Int
        /// `Error.userInfo["condition":?]`
        let name: String?
        
        switch self {
        case .urlError(let url) : code =  1; name = url.absoluteString
        case .strError(let str) : code =  2; name = str
        default                 : code = -1; name = nil
        }
        
        var userInfo: [String:Any] = [:]
        if let name { userInfo["condition"] = name }
        
        let nsErr = NSError(domain: Self.domain, code: code, userInfo: userInfo)
        return nsErr
    }
}

import UniformTypeIdentifiers

/* Not used, but useful to have around, like SimpleWebView */
/// Given a file name, putatively with an extension, derive a preferred MIME type, as determined by the `UniformTypeIdentifiers` module.
///
/// If none can be found, defaults to "`multipart/form-data`"
/// - bug: `form-data` doesn't _sound_ like an ID for undifferentiated data, but there seems not to be anything else.
/// - Parameter remoteName: The name of the file from which to derive the type
/// - Returns: `String`, representing the preferred MIME  type.
extension String {
    func mimeType() -> String {
        let nameParts = self
            .split(whereSeparator: { ch in
                return Character(".") == ch } )
        // Does the final split of the remote name exist?
        // Does the UTI framework have a preferred type for it?
        guard let suffix = nameParts.last,
              let typeReference =
                UTTypeReference(filenameExtension: String(suffix)),
              let retval = typeReference.preferredMIMEType
        else {
            return "multipart/form-data"
        }
        return retval
    }
}

fileprivate func isGoodHost(_ host: String) -> Bool {
    let goodSide = ["edu", "uchicago"]
    let questSide = host.split(separator: ".").reversed().map { String($0) }
    guard questSide.count >= goodSide.count else { return false }
    let okayDomain = zip(goodSide, questSide).allSatisfy {$0 == $1}
    return okayDomain
}


extension String {
    /// Whether this `String` stands for a host whose name ends in `uchicagp.edu`. Better than a simple `.hasSuffix("uchicago.edu")` because it accepts `uchicago.edu` and resists an injectition like `bogusuchicago.edu`
    public var isUChicagoHost: Bool {
        isGoodHost(self)
    }
}


let _yyyy_mm_dd: DateFormatter = {
    let retval = DateFormatter()!
    retval.dateFormat = "yyyy-MM-dd_hh:mm"
    return retval
}()

let _yyyy_mm_dd_hm_ss: DateFormatter = {
    let retval = DateFormatter()!
    retval.dateFormat = "yyyy-MM-dd_hh:mm:ss"
    return retval
}()


extension Date {
    public var ymd: String {
        _yyyy_mm_dd.string(from: self)
    }
    public var ymd_hms: String {
        _yyyy_mm_dd_hm_ss.string(from: self)
    }
}
