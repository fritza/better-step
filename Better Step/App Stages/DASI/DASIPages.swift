//
//  DASIPages.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/14/22.
//

import Foundation
import Combine

/// Observable selection of a DASI question, such as for question-page navigation
///
///Initialized in
/// - `BetterStep_App` (root `environmentObject(_:)`)
///
/// Used in:
/// - `SurveyContainerView`
/// - `DASIQuestionView`
/// - `DASICompleteView`
/// - `DASIOnboardView`
/// - `SurveyContainerView`
/// - `YesNoButton` (**Pull out as a dependency?**
/// - `ApplicationOnboardView` (**Wrong Place**)
final class DASIPages: ObservableObject, SubjectIDDependent {
    @Published var selected: DASIStages!
    @Published var refersToQuestion: Bool

    init(_ selection: DASIStages = .landing) {
        selected = selection
        refersToQuestion = selection.refersToQuestion
    }

    func teardownFromSubjectID() async throws -> DASIPages? {
        let newSelection = DASIStages.landing
        selected = newSelection
        refersToQuestion = newSelection.refersToQuestion
        return self
    }

    /// Reflect the selection of the next page.
    ///
    /// At the end of the question pages, this should advance to `.completion`. There is no increment from `.completion`.
    func increment() {
        selected.goForward()
        refersToQuestion = selected.refersToQuestion
    }

    /// Reflect the selection of the previous page.
    ///
    /// From the start of the question pages, this should regress to `.landing`. There is no decrement from `.landing`.
    func decrement() {
        selected.goBack()
        refersToQuestion = selected.refersToQuestion
    }

    var questionIdentifier: Int? {
        guard let containedID = selected.questionIdentifier else {
            return nil
//            preconditionFailure(
//                "selected wasn't a .presenting.")
        }
        return containedID
    }
}


