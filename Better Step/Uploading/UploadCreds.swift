//
//  UploadCreds.swift
//  DataTaskMinimal
//
//  Created by Fritz Anderson on 1/16/23.
//

import Foundation

/// Holder for various constants (URLs/paths, username, password).
///
/// These are conditioned on the stage of development and the corresponding configurations for hosts, credentials, etc.
///  * `API_DEV`: Application development for free use by application developers.
///  * `BETA_API`: Releasable to statkeholders for testing.
///  * _\<none\>_ - Production use, no data except for clinical use.
/// - bug: Constants have accumulated and been abandoned throughout a weeks-long development process. Review these.
public enum UploadCreds {
#if API_DEV
    // Use for internal test and development
    /// The LastPass name for the credentials
    static let lastPassName     = "Step Test Files API (dev and stage)"
    /// **Host** address of the server (`String`)
    static let hostString       = "https://steptestfilesdev.uchicago.edu"

    /// The fill URL path to the uploads directory.
    ///
    /// Stop being fancy with building up from the host name.
    static let fullUploadString = "https://steptestfilesdev.uchicago.edu/api/upload"

    /// UTTP  Basic iuser name (`String`)
    static let userID           = "iosuser"
    /// UTTP  Basic password (`String`)
    static let password         = "sliD3gtorydra"
#elseif BETA_API
    // Use for TestFlight
    /// The LastPass name for the credentials
    static let lastPassName     = "Step Test Files API (dev and stage)"
    /// **Host** address of the server (`String`)
    static let hostString       = "https://steptestfilesstage.uchicago.edu"

    /// The fill URL path to the uploads directory.
    ///
    /// Stop being fancy with building up from the host name.
    static let fullUploadString = "https://steptestfilesstage.uchicago.edu/api/upload"

    /// UTTP  Basic iuser name (`String`)
    static let userID           = "iosuser"
    /// UTTP  Basic password (`String`)
    static let password         = "sliD3gtorydra"
#else
    // Public-release (production server)
    /// The LastPass name for the credentials
    static let lastPassName     = "Step Test Files API (PROD)"
    /// **Host** address of the server (`String`)
    static let hostString       = "https://steptestfiles.uchicago.edu"
    /// The fill URL path to the uploads directory.
    ///
    /// Stop being fancy with building up from the host name.
    static let fullUploadString = "https://steptestfiles.uchicago.edu/api/upload"
    /// UTTP  Basic iuser name (`String`)
    static let userID           = "iosuser"
    /// UTTP  Basic password (`String`)
    static let password         = "wayB3aundanar"
#endif

    /// `URL` for the host server (derived from `hostString`)
    static let hostURL           = URL(string: hostString)!
    /// Components of the upload API path (`[String]`) to append to the `hostURL`. Used because `appendingPathComponent` was erroneous
    static let pathComps         = ["api", "upload"]
    /// API path on the host for uploading. (`String`).
    static let hostPathComponent = "/api/upload"
    /// `URL` for the fuily-qualified API address.
    static let uploadDirURL      = pathComps.reduce(hostURL) { partURL, component in
        let loopResult = partURL.appendingPathComponent(component, isDirectory: false)
        return loopResult
    }

    static let method            = "POST"
}
