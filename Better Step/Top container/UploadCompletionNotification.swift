//
//  UploadCompletionNotification.swift
//  DataTaskMinimal
//
//  Created by Fritz Anderson on 2/10/23.
//

import Foundation
import STUploading

/// `Notification` of a successful upload. `object` is the `Data` that was uploaded.
public let UploadNotification      = Notification.Name("UploadNotification"     )
/// `Notification` of a failed upload (in the sense of an application error, not a server-side status.. `object` is the system `Error`.
public let UploadErrorNotification = Notification.Name("UploadErrorNotification")

/// Adopter of `LocalizedError` to wrap a generic `Error` into one that can populate an alert
struct LocalizedUploadError: LocalizedError {
    /// The `Error` the `LocalizedUploadError` stands for
    let underlying: Error
    init(_ error: Error) { underlying = error }
    
    /// Adoption: Derive the alert-ready description from the Error's localizedDescription.
    var errorDescription: String? {
        underlying.localizedDescription
    }
}

/// Observable status helper standing for the latest `Error` state and a  flag for disclosing an error alert.
final class UploadState: ObservableObject {
    @Published var status: Result<Data, Error>
    
    /// The `LocalizedUploadError` represented in this wrapper.
    @Published var error: LocalizedUploadError? {
        didSet {
            shouldShowError = error != nil
        }
    }
    
    /// Flag to signal an alert modifier to display the alert.
    @Published var shouldShowError: Bool = false
    
    /// Convenience: Set the `LocalizedUploadError`  condition from an unwrapped `Error`
    func setFromError(_ foundationError: Error) {
        error = LocalizedUploadError(foundationError)
    }
    
    init() {
        status = .failure(SimpleErrors.strError("Not yet set."))
        error  = nil
    }
}
