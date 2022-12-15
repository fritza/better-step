//
//  WalkingContainerResult.swift
//  Better Step
//
//  Created by Fritz Anderson on 10/5/22.
//

import Foundation
import Combine

/// Holds two `IncomingAccelerometry`s, for both walk speeds. There is no public initializer; use ``WalkingContainerResult```.shared`.
///
/// ``WalkingContainerResult``receives an ``IncomingAccelerometry`` for each `.walk_n` stage. When it's full, the data is ready to export. It's awkward, but it allows ``WalkingContainerView/walk_N_View(ownPhase:nextPhaseGood:nextPhaseBad:)`` to fill in the per-walk result by index rather than hard-code it.
///
/// Use the singleton `WalkingContainerResult.shared`.
public final class WalkingContainerResult {
    /// Completed data from the first (slow) walk.
    private var accData1: IncomingAccelerometry?
    /// Completed data from the first (fast) walk.
    private var accData2: IncomingAccelerometry?

    /// Initializer; not for public use, use `.shared` instead.
    private init(accData1: IncomingAccelerometry? = nil,
                 accData2: IncomingAccelerometry? = nil) {
        self.accData1 = accData1
        self.accData2 = accData2
    }

    /// The singleton `WalkingContainerResult`; there is no public initializer.
    public static let shared = WalkingContainerResult()

    /// The walk data (`IncomingAccelerometry` x2) is ready for export when both walk records have been filled.
    public var readyForExport: Bool { accData1 != nil && accData2 != nil }

    /// If there are two completed walks in the record, convert them to CSV, write them to files, and add them to the accelerometry `.zip` file.
    /// - returns: whether two values were present, and therefore ready. This does _not_ reflect the archive’s successful creation.
    @discardableResult
    public func exportWalksIfReady(tag: String, subjectID: String) -> Bool {
        guard let accData1, let accData2 else { return false }
        Task.detached {
            // NOTE: we know both are filled because of the guard.
            try? await accData1.addToArchive(tag: tag, subjectID: SubjectID.id)
            try? await accData2.addToArchive(tag: tag, subjectID: SubjectID.id)
            // FIXME: do something about export failures.
        }
        return true
    }

#if OUTPUT_ASYNC
    @discardableResult
    public func asyncExportWalksIfReady() async -> Bool {
#if true
        fatalError("to be ported")
#else
        guard let accData1, let accData2 else { return false }
#warning("see if PhaseStorage is better")
        let exportValue = await Task<Void, Error> {
            try await accData1.addToArchive()
            try await accData2.addToArchive()
        }
            .result
        switch exportValue {
        case.success:   return true
        case let .failure(err):
            // Do something with the error
            return false
        }
#endif
    }
#endif

    /// Convenience setter for walks 1 and 2.
    ///
    /// Clear the walk data by setting `nil`.
    /// - warning: access vis a non-walk phase is fatal.
    private func set(data: IncomingAccelerometry?, for phase: WalkingState) {
        #warning("Port to PhaseStorage call")
        switch phase {
        case .walk_1:   self.accData1 = data
        case .walk_2:   self.accData2 = data
        default:
            fatalError("\(#function): unexpected phase")
        }
    }

    /// Connvenience access to walks 1 and 2
    /// - warning: access vis a non-walk phase is fatal.
    public subscript(_ phase: WalkingState) -> IncomingAccelerometry? {
        get {
            switch phase {
            case .walk_1:   return self.accData1
            case .walk_2:   return self.accData2
            default:
                fatalError("\(#function) get: unexpected phase")
            }
        }
        set {
#warning("Port to PhaseStorage call")
            set(data: newValue, for: phase)
        }
    }
}
