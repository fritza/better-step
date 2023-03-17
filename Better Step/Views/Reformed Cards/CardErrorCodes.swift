//
//  CardErrorCodes.swift
//  Gallery
//
//  Created by Fritz Anderson on 3/14/23.
//

import Foundation
// MARK: - CardErrorCodes
enum CardErrorCodes {
    // Reading
    case noURL(String)
    case noData(String)
    case notDecoded(Error)
    // Image
    case noImageSpecified
    
    
    /// Create an `NSError`
    /// - Returns: `NSError` initialized with domain, code, and description
    func nsError() -> NSError {
        let localized: String
        let code: Int
        switch self {
        case let .noURL(base):
            localized = "No file in Bundle: \(base)"
            code = 1
        case let .noData(base):
            localized = "No data in file: \(base)"
            code = 2
        case let .notDecoded(error):
            localized = "Not decoded: \(error)"
            code = 3
            
        case .noImageSpecified:
            localized = "Image: Neither a systemName nor an image file specified"
            code = 100
        }
        
        let info: [String:Any] = [
            NSLocalizedDescriptionKey: localized
        ]
        return NSError(domain: CardContent.errorDomain,
                       code: code, userInfo: info)
    }
}

