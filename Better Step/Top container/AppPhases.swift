//
//  AppPhases.swift
//  Better Step
//
//  Created by Fritz Anderson on 4/10/23.
//

import Foundation

// MARK: - AppPhases
enum AppPhases: String, CaseIterable {
    // MARK: Read/write defaults

    /// Convenience function for setting the ``ASKeys.phaseProgress`` default.
    @discardableResult
    private static func setDefaults(to phase: AppPhases) -> AppPhases {
        let ud = UserDefaults.standard
        let key = ASKeys.phaseProgress.rawValue
        ud.set(phase.rawValue, forKey: key)
        return phase
    }

    /// Accessor for the ``ASKeys.phaseProgress`` default.
    /// - note: Client code may not mutate this property
    public private(set) static var current: AppPhases {
        get {
            let ud = UserDefaults.standard
            let key = ASKeys.phaseProgress.rawValue
            guard let retval = ud.string(forKey: key) else {
                return setDefaults(to: .entry)
            }
            return AppPhases(rawValue: retval)!
        }
        set {
            setDefaults(to: newValue)
        }
    }

    // MARK: Cases
    case greeting
    case onboarding
    case walking
    case dasi
    case usability
    case conclusion

    case entry

    // MARK: Life cycle: next
    /// The ``AppPhases`` succeeding `self`.
    /// - note: This property has no side effects. It does not mutate the enum value.
    var next: AppPhases {
        switch self {
        case .greeting, .onboarding:    return .walking
        case .dasi:                     return .usability

        case .conclusion:               return .entry
        case .usability:                return .conclusion

        case .entry: return ASKeys.isFirstRunComplete ?
                .greeting : .onboarding
        case .walking:
            return ASKeys.isFirstRunComplete ?
                .conclusion : .dasi
        }
    }

    // MARK: Life cycle: reset/advance
    /// Reset the `UserDefaults` ``AppPhases`` to `.entry`.
    /// - Returns: The resulting phase (`.entry`(
    @discardableResult
    static func reset() -> AppPhases {
        current = .entry; return .entry
    }

    /// Advance static/`AppStorage`  value of the phase, adjusted for whether this is first-run.
    /// - note: Unlike ``next``, this function _does_ have side-effects (current phaes, optionally ``ASKeys.isFirstRunComplete``.
    /// - Parameter settingFirstRun: if `true`, and the resulting next phase is `.entry`, set  ``ASKeys.isFirstRunComplete``
    /// - Returns: The resulting ``AppPhases``.
    @discardableResult
    static func advance(settingFirstRun: Bool = false) -> AppPhases {
        let nextValue = current.next
        current = nextValue

        if settingFirstRun {
            ASKeys.isFirstRunComplete = nextValue == .entry
        }

        #if DEBUG
        print(#function, "Advancing to", nextValue)
        #endif

        return nextValue
    }

    var description: String { self.rawValue }
}

