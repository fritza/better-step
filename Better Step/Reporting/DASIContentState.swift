//
//  DASIContentState.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/14/22.
//

import Foundation
import Combine

/// Observable wrapper on a persistent `DASIStages`.
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
final class DASIContentState: ObservableObject {
    @Published var selected: DASIStages!

    init(_ selection: DASIStages = .landing) {
        selected = selection
        refersToQuestion = selection.refersToQuestion
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

    @Published var refersToQuestion: Bool
    var questionIdentifier: Int? {
        guard let containedID = selected.questionIdentifier else {
            return nil
//            preconditionFailure(
//                "selected wasn't a .presenting.")
        }
        return containedID
    }
}


