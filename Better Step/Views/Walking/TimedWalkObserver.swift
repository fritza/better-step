//
//  TimedWalkObserver.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/19/22.
//


/*
 TimedWalkObserver belongs to the walking view.
the accels are in .consumer
 */

import Foundation
import CoreMotion

#warning("unify MotionManager.lifecycle and self.isCancelled")



/// ## Topics
///
/// ### Properties
///
/// - ``consumer``
/// - ``title``
/// - ``isRunning``
///
/// ### Initialization
///
/// - ``init(title:)``
///
/// ### Life Cycle
///
/// - ``start()``
/// - ``testableStart()``
/// - ``reset()``
/// - ``stop()``
/// - ``clearRecords()``
///
/// ### AccelerometryConsuming
///
/// - ``append(_:)``
/// - ``append(contentsOf:)``
/// -  ``allRecords()``
///
/// ### Marshalling
///
/// - ``marshalledRecords(withPrefix:)``
/// - ``allAsCSV(withPrefix:)``
/// - ``allAsData(prefixed:)``
/// - ``write(withPrefix:to:)``
/// - ``writeToFile(named:linesPrefixedWith:)``
/// - ``writeToFile(walkState:)``

// MARK: - TimedWalkObserver
/// Non-view-related code that consumes and stores accelerometer data.
///
/// `TimedWalkObserver` bridges collection of observations (`async for` loop  as ``AccelerometryConsuming``) to marshalling and file output ( functions beginning `write`).
final class TimedWalkObserver: ObservableObject, CustomStringConvertible {
    // FIXME: The long-term storage object
    //        ought to be an actor.
    /// The list of observation elements
    var consumer: [AccelerometerDataContent]
    /// Distinguishing label for the observer.
    var title: String
    /// Whether the observer should be open to observations.
    var isRunning: Bool

    // MARK: Initializer
    /// Initialize with a title. The list is empty, `isRunning` is `false`.
    init(title: String) {
        self.title = title
        consumer = []
        isRunning = false
    }

    var description: String {
        "TimedWalkObserver ("
        + (isRunning ? "Running" : "Stopped")
        + ", \(consumer.count)) “\(title)”"
    }

    // MARK: Start/stop
    /// Start the motion manager collecting accelerometry.
    ///
    /// Reports are collected through a `try await for` loop. If the loop iterator throws, the motion manager is cancelled.
    func start() async {
        isRunning = true
        MotionManager.shared.start()
        Task {
            do {
                for try await datum in MotionManager.shared {
                    consumer.append(datum)
                }
            }
            catch {
                MotionManager.shared.lifecycle = .error(error)
                isRunning = false
                print("\(#file):\(#line): the incoming data loop threw", error)
            }
        }
    }

    /// Tear down the previous run of the manager in preparation for another run.
    func reset() {
        stop()
        clearRecords()
    }

    /// Halt the Core Motion updates.
    func stop() {
        // FIXME: sholdn't have to rely on singleton
        MotionManager.shared.halt()
        isRunning = false
    }

    /// Remove all records from the observer (whatever that might be).
    func clearRecords() {
        assert(!isRunning)
        consumer.removeAll()
    }
}

// MARK: AccelerometryConsuming

extension TimedWalkObserver: AccelerometryConsuming {
    /// ``AccelerometryConsuming`` compliance
    /// 
    /// Add one `AccelerometerDataContent` to the `Deque` buffer.

    func append(_ record: AccelerometerDataContent) {
        consumer.append(record)
    }

    /// ``AccelerometryConsuming`` compliance
    ///
    /// Add an array of `AccelerometerDataContent` to the `Deque` buffer.
    func append(contentsOf array: [AccelerometerDataContent]) {
        consumer.append(contentsOf: array)
    }

    /// ``AccelerometryConsuming`` compliance
    ///
    /// Retrieve the entire (current) contents of the `Deque` buffer.
    func allRecords() -> [AccelerometerDataContent] {
        return consumer
    }
    // The default implementation is fine.
    // func marshalledRecords() -> [String]

// MARK: Marshalling

    /// Supplementary marshalling which adds  prefix to each line.
    /// - Parameter prefix: A fragment of CSV that will be added to the front of each record. Any trailing comma at the end will be omitted.
    /// - Returns: An array of `Strings` consisting of `\_prefix` + "," + `marshalled record`.
    /// - warning:Removing a comma from the end of `\_prefix` is a choice of convenience over edge cases.  Clients that _want_ to interpose a comma will find there's no clean way to do it.
    func marshalledRecords(withPrefix _prefix: String) -> [String] {
        let plainMarshalling = marshalledRecords()
        guard !_prefix.isEmpty else { return plainMarshalling }

        let prefix = (_prefix.last! == ",") ? _prefix : _prefix+","
        return plainMarshalling
            .map { prefix + $0}
    }

    /// A `String` containing each line of the CSV data
    ///   - parameter prefix: A fragment of CSV that will be added to the front of each record. Any trailing comma at the end will be omitted. _See_ the note at ``TimedWalkObserver/marshalledRecords(withPrefix:)``
    ///
    /// - Returns: A single `String`, each line being the marshalling of the `CMAccelerometerData` records
    func allAsCSV(withPrefix prefix: String) -> String {
        return marshalledRecords(withPrefix: prefix)
            .joined(separator: "\r\n")
    }

    /// A `Data` instance containing the entire text of a CSV `String`
    ///
    /// This is a simple wrapper that takes the result of `allAsCSV(withPrefix:)` and renders it as bytes.
    ///   - parameter prefix: A fragment of CSV that will be added to the front of each record. Any trailing comma at the end will be omitted. _See_ the note at ``TimedWalkObserver/marshalledRecords(withPrefix:)``
    func allAsData(prefixed prefix: String) -> Data {
        let content = allAsCSV(withPrefix: prefix)
        guard let data = content.data(using: .utf8) else { fatalError("Could not derive Data from the CSV string") }
        return data
    }

    // MARK: Writing

    func addToArchive(tag: String) throws {
        // TODO: Throwing
        let prefix = "\(tag),\(SubjectID.id)"
        let data = allAsData(prefixed: prefix)
        try CSVArchiver.shared
            .writeData(data, forTag: tag)
    }

//    static var filePaths: [String] = []
//    static func registerFilePath(_ name: String) {
//        while filePaths.count > 2 {
//            filePaths.removeFirst()
//        }
//        filePaths.append(name)
//    }

    /// Write all CSV records into a file.
    /// - Parameters:
    ///   - prefix: A fragment of CSV that will be added to the front of each record. Any trailing comma at the end will be omitted. _See_ the note at ``marshalledRecords(withPrefix:)``
    ///   - url: The location of the new file.
    func write(withPrefix prefix: String, to url: URL) throws {
        // TODO: Make it async
        let fm = FileManager.default
        let data = allAsData(prefixed: prefix)
        try fm.deleteAndCreate(at: url, contents: data)
//        Self.registerFilePath(url.path)
    }

    /// Marshall all the `CMAccelerometerData` data and write it out to a named file in the Documents directory.
    /// - Parameters:
    ///   - fileName: The base name of the target file as a `String`. No extension will be added.
    ///   - prefix: A fragment of CSV that will be added to the front of each record. Any trailing comma at the end will be omitted. _See_ the note at ``marshalledRecords(withPrefix:)``
    func writeToFile(named fileName: String,
                     linesPrefixedWith prefix: String) throws {
        precondition(!fileName.isEmpty,
                     "\(#function): empty prefix string")
        let destURL = try FileManager.default
            .docsDirectory(create: true)
            .appendingPathComponent(fileName)
            .appendingPathExtension("csv")

        try write(withPrefix: prefix, to: destURL)
    }

    // FIXME: - URGENT - get a way to have a global subject ID.
    static var lastData = try! CSVArchiver()

    func writeForArchive(tag: String) throws {
        let prefix = "\(tag),\(SubjectID.id)"
        let content = allAsData(prefixed: prefix)
        // writeData(_:forTag:) raises ZIPProgressNotice
        try Self.lastData.writeData(content, forTag: tag)
    }

    func outputBaseName(walkState: WalkingState) -> String {
        let isoDate = Date().iso
        let state = walkState.csvPrefix
        // Force-unwrap: The phase _will_ be .walk_N, which _will_ have a prefix.
        return "Sample-\(state!):\(isoDate)"
    }

    func writeToFile(walkState: WalkingState) throws {
        precondition(walkState == .walk_2 || walkState == .walk_1,
                     "Unexpected walk state \(walkState)"
        )
        let baseName = outputBaseName(walkState: walkState)
        try writeToFile(
            named: baseName,
            linesPrefixedWith: "\(walkState.csvPrefix!),Sample")
    }
}
