//
//  AppStages.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/16/22.
//

import Foundation
import Combine

// MARK: - AppStage class
/// Observable tracker of the `AppStages`: The currently-displayed stage from the `TabView`, and the stages that have been marked complete
///
/// **Take care** not to confuse `AppStage` (observable `class`) and `AppStages` (`enum` identifying stages). The type system should help with this.
final class AppStage: ObservableObject {
    static let shared = AppStage()
    /// The `Set` of `AppStages` that have been marked complete.
    @Published var completionSet: Set<AppStages> = []
    @Published var currentSelection: AppStages

    private init(stage: AppStages = .onboard) {
        currentSelection = stage
    }
}
// FIXME: A watcher of AppStage.shared could generate a report
//        when the completionSet is found to include its tag.
//        This does repeat the creation every time _any_ phase
//        completes.

// MARK: - AppStages enum
enum AppStages: Hashable, CaseIterable {
    // MARK: Cases
    /// A new user ID has been entered.
    case onboard
    /// The user has completed these activities
    case dasi, walk
    /// The user has entered the Report tab
    ///
    /// You can't report without a `subjectID`
    case report
    case configuration

    // MARK: Static attributes
    private static let _imageNames: [AppStages:String] = [
        .onboard: "circle.fill",
        .dasi: "checkmark.square",
        .walk: "figure.walk",
        .report: "doc.text",
        .configuration: "gear"
        ]
    var imageName: String { Self._imageNames[self]! }

    private static let _visibleNames: [AppStages:String] = [
        .onboard: "•start•",
        .dasi: "Survey",
        .walk: "Walk",
        .report: "Report",
        .configuration: "Setup",
    ]

    var visibleName: String  { Self._visibleNames[self]! }
    var tabBadge   : String? {
        let completed = AppStage.shared.completionSet.contains(self)
        return completed ?  "✓" : nil
    }
}

// MARK: - AppStage dependent
extension AppStages {
    /// Whether this stage has been marked complete.
    ///
    /// This is done with reference to `AppStage.shared`.
    /// Think of it as a convenience view into `AppStage`'s bookkeeping.
    var isComplete: Bool {
        return AppStage.shared.completionSet
            .contains(self)
    }

    /// Declare that this stage has been completed.
    ///
    /// This is done with reference to `AppStage.shared`.
    /// Think of it as a convenience view into `AppStage`'s bookkeeping.
    func didComplete() {
        AppStage.shared.completionSet.insert(self)
    }

    /// Declare that this stage has _not_ been completed.
    ///
    /// This is done with reference to `AppStage.shared`.
    /// Think of it as a convenience view into `AppStage`'s bookkeeping.
    func makeIncomplete() {
        AppStage.shared.completionSet.remove(self)
    }

    /// Declare that _no_ stages have been completed.
    ///
    /// This is done with reference to `AppStage.shared`.
    /// Think of it as a convenience view into `AppStage`'s bookkeeping.
    func makeAllIncomplete() {
        for stage in Self.allCases {
            stage.makeIncomplete()
        }
    }

    /// Whether this stage is to be presented and must be completed before reporting.
    ///
    /// `RootState` is a dependency because preferences determine whether walk and dasi are needed.
    var isRequired: Bool {
        switch self {
        case .onboard       : return false
        case .dasi          : return RootState.shared.includeSurvey
        case .walk          : return RootState.shared.includeWalk
        case .report        : return false
        case .configuration : return false
        }
    }

    static var areRequiredStagesComplete: Bool {
        Self.allCases
            .filter(\.isRequired)
            .allSatisfy {
                AppStage.shared.completionSet.contains($0)
            }
    }
}

