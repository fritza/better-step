//
//  RootState.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/28/22.
//

import Foundation
import SwiftUI
import Combine

final class AppStage: ObservableObject {
    static let shared = AppStage()
    @Published var completionSet: Set<AppStages> = []
    @Published var currentSelection: AppStages

    init(stage: AppStages = .onboard) {
        currentSelection = stage
    }
}
// FIXME: A watcher of AppStage.shared could generate a report
//        when the completionSet is found to include its tag.
//        This does repeat the creation every time _any_ phase
//        completes.

enum AppStages: Hashable, CaseIterable {
    /// A new user ID has been entered.
    case onboard
    /// The user has completed these activities
    case dasi, walk
    /// The user has entered the Report tab
    ///
    /// You can't report without a `subjectID`
    case report
    case configuration

    static let _imageNames: [AppStages:String] = [
        .onboard: "circle.fill",
        .dasi: "checkmark.square",
        .walk: "figure.walk",
        .report: "doc.text",
        .configuration: "gear"
        ]
    var imageName: String { Self._imageNames[self]! }

    static let _visibleNames: [AppStages:String] = [
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
//        return isComplete ?  "✓" : nil
    }

    var isComplete: Bool {
        return AppStage.shared.completionSet
//        return RootState.shared.completed
            .contains(self)
    }

    func didComplete() {
        AppStage.shared.completionSet.insert(self)
//        RootState.shared.completed.insert(self)
    }

    func makeIncomplete() {
        AppStage.shared.completionSet.remove(self)
//        RootState.shared.completed.remove(self)
    }

    func makeAllIncomplete() {
        for stage in Self.allCases {
            stage.makeIncomplete()
        }
    }

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

final class RootState: ObservableObject {
    static var shared = RootState()
    private init() {

    }


   static let noSubjectString = "NO SUBJECT"
    // NOTE: Update @AppStorage - subjectID

    // Leave things like includeWalk to be initialized by the config view or the root of the DASI and Walk hierarchies.

    @AppStorage(AppStorageKeys.subjectID.rawValue) var subjectID: String = "NO SUBJECT"
    // NOTE: Update constant noSubjectString
    // TODO: no-subject and onboarding
    //       the sheet should recognize no-subject and empty the field.

    // MARK: - Phase management

    // Structural
    @AppStorage(AppStorageKeys.includeWalk.rawValue)    var includeWalk = true
    @AppStorage(AppStorageKeys.includeSurvey.rawValue)  var includeSurvey = true

    // Stages
    var currentStage: AppStages = .onboard
    fileprivate var completed     : Set<AppStages> = []


    // DASI
    var dasiProgress: DASIPages = DASIPages()
    var dasiResponses: DASIResponses = DASIResponses()

    // Walk
}

final class ApplicationState: ObservableObject {
    @AppStorage(AppStorageKeys.includeWalk.rawValue)    var includeWalk = true
    @AppStorage(AppStorageKeys.includeSurvey.rawValue)  var includeSurvey = true

    static var current: ApplicationState!

    private var completed     : Set<AppStages> = []
    private var requiredPhases: Set<AppStages> {
        var retval = Set<AppStages>()
        if includeWalk   { retval.insert(.walk) }
        if includeSurvey { retval.insert(.dasi) }
        assert(!retval.isEmpty,
               "Must set at least one of includeWalk, includeSurvey")
        return retval
    }

    init() {
        let ud = UserDefaults.standard
        subjectID = ud.string(forKey: AppStorageKeys.subjectID.rawValue)
        ?? ""
        Self.current = self
    }

    @Published var subjectID: String = "νεμο" {
        didSet {
            #warning("This resets progress while typing, even if it would eventually match")
            if subjectID != oldValue {
//                clear(newUserID: subjectID)
                completed = []
                }
            completed = [.onboard]


            #warning("Make sure this is the right place to update the subjectID")
            let ud = UserDefaults.standard
            ud.set(subjectID, forKey: AppStorageKeys.subjectID.rawValue)
        }
    }

    /// Clear out the completion records, optionally setting a new `subjectID`
    ///
    /// If no (`nil`) subject ID is provided, the existing subject ID will be preserved.
    /// - parameter newUserID: The subject ID for the exercise. If `nil`, ( the default), the global subject ID will not be changed.
    func clear(newUserID: String? = nil) {
        completed  = []
        if let newUserID = newUserID {
            subjectID = newUserID
        }
        else {
            subjectID = ""
        }
    }

    @Published var allTasksFinished: Bool = false

    /// Mark this phase of the run as complete.
    func didComplete(phase: AppStages) {
        updateReadiness(setting: phase, finished: true)
    }
    /// Mark this phase of the run as incomplete.
    func didNotComplete(phase: AppStages) {
        updateReadiness(setting: phase, finished: false)
    }

    func isCompleted(_ stage: AppStages) -> Bool {
        completed.contains(stage)
    }

    func areCompleted<S: Collection>(settings: S) -> Bool
    where S.Element == AppStages
    {
        let retval = settings.allSatisfy { element in
            isCompleted(element)
        }
        return retval
    }

    private func updateReadiness(setting stage: AppStages, finished: Bool) {
        let wasReady = checkReadyToReport

        if finished { completed.insert(stage) }
        else { completed.remove(stage)  }

        let amReady = checkReadyToReport
        if wasReady != amReady {
            allTasksFinished = amReady
        }
    }

    /// Whether the active tasks (survey and tasks) have all been completed _and_ there is a known subject ID;
    var checkReadyToReport: Bool {
        if subjectID == "" { return false }
        let allCompleted = completed
            .intersection(requiredPhases)
        return allCompleted == requiredPhases
    }
}

