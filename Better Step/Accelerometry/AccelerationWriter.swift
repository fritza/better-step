//
//  AccelerationWriter.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/20/22.
//

import Foundation
import CoreMotion

final class AccelerationWriter {
    typealias InputStream = AsyncStream<CMAccelerometerData>
    let stream: InputStream
    let outputURL: URL
    let outputHandle: FileHandle

    // Can I detect changes to SubjectID.shared.subjectID?
    /// Create a stream of CSV `Data` derived from a stream of `CMAccelerometerData`, then append it to a file at `destinationURL`.
    ///
    /// If a file already exsts at `destinationURL`, it is deleted/overwritten.
    /// - precondition: The directory that is to contain the log `Data` must exist.
    /// - Parameter destinationURL: The URL for the file to be written to.
    /// - throws: `FileManager`: errors from `removeItem`.`FileHandle`:  creating write handle. `FileStorageErrors: can't create the destination file.
    init(to destinationURL: URL) throws {
        let fm = FileManager.default
        // Best to fail before setting any properties.
        try fm.deleteAndCreate(at: destinationURL)

        outputURL = destinationURL
        outputHandle = try FileHandle(
            forWritingTo: destinationURL)
        stream = MotionManager.shared.stream
    }

    /*
     I know we need to write data into a url.
     I _think_ we can count on the file's having no useful content (or not existing) upon call.


     */
    func runCollection(intoURL destinationURL: URL) async throws {
        let fm = FileManager.default
        try fm.deleteAndCreate(at: destinationURL)

        let itemStream = stream
            .map { AccelerometerItem($0) }
            .map(\.csv)
            .map { $0 + "\r\n" }
            .compactMap { $0.data(using: .utf8) }
        do {
            let outHandle = try  FileHandle(
                forWritingTo: destinationURL)
            // defer can't throw, but I need to
            // cover all exits.
            defer { try? outHandle.close() }
            for await item in itemStream {
                try outHandle.write(contentsOf: item)
            }
        }
    }
    // TODO: How is this to be terminated?
    //       An async continuation can be
    //       sent .finish() instead of
    //       .yield(_:Element). That terminates
    //       the loop, returning nil every time.
}
