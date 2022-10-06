//
//  WalkingContainerResult.swift
//  Better Step
//
//  Created by Fritz Anderson on 10/5/22.
//

import Foundation
import Combine

public final class WalkingContainerResult: ObservableObject {

    @Published var walk_1: IncomingAccelerometry?
    @Published var walk_2: IncomingAccelerometry?

    public static let shared = WalkingContainerResult()

   public  var readyForExport: Bool { walk_1 != nil && walk_2 != nil }

    /// Convenience setter for walks 1 and 2.
    ///
    /// Clear the walk data by setting `nil`.
    /// - warning: access vis a non-walk phase is fatal.
    public func set(data: IncomingAccelerometry?, for phase: WalkingState) {
        switch phase {
        case .walk_1:   self.walk_1 = data
        case .walk_2:   self.walk_2 = data
        default:
            fatalError("\(#function): unexpected phase")
        }
    }

    /// Connvenience access to walks 1 and 2
    /// - warning: access vis a non-walk phase is fatal.
    public subscript(_ phase: WalkingState) -> IncomingAccelerometry? {
        get {
            switch phase {
            case .walk_1:   return self.walk_1
            case .walk_2:   return self.walk_2
            default:
                fatalError("\(#function) get: unexpected phase")
            }
        }
        set {
            set(data: newValue, for: phase)
        }
    }
}
