//
//  DASIPageSelection.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/14/22.
//

import Foundation
import SwiftUI
import Combine

/// Observable selection of a DASI question, such as for question-page navigation. **This is just SELECTION, state for paging through the questions, it has no content
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

enum DASIState {
    case landing, question, completed, NONE
}

final class DASIPageSelection: ObservableObject
{
    @Published var selected: DASIStages!
    @Published var pagerState: DASIState? = .landing

    @Published var isLanding  : Bool
    @Published var isQuestion : Bool
    @Published var isCompleted: Bool

    private func reconcileBoolState(bySetting new: DASIState) {
        pagerState = new

        switch new {
        case .landing:
            isLanding = true
            isQuestion = false
            isCompleted = false

        case .question:
            isLanding = false
            isQuestion = true
            isCompleted = false

        case .completed:
            isLanding = false
            isQuestion = false
            isCompleted = true

        case .NONE:
            isLanding = false
            isQuestion = false
            isCompleted = false
        }
    }



    init(_ selection: DASIStages = .landing) {
        selected = selection
//        refersToQuestion = selection.refersToQuestion
        isLanding = true
        isQuestion = false
        isCompleted = false

        reconcileBoolState(bySetting: .landing)
    }

    deinit {
        print("DASIPageSelection goes away.")
    }

    /// Reflect the selection of the next page.
    ///
    /// At the end of the question pages, this should advance to `.completion`. There is no increment from `.completion`.
    func increment() {
       selected = selected.incremented()
        switch selected {
        case .landing: reconcileBoolState(bySetting: .landing)
        case .presenting(_): reconcileBoolState(bySetting: .question)
        case .completion: reconcileBoolState(bySetting: .completed)
        case .none:
            reconcileBoolState(bySetting: .NONE)
        }
    }

    /// Reflect the selection of the previous page.
    ///
    /// From the start of the question pages, this should regress to `.landing`. There is no decrement from `.landing`.
    func decrement() {
        selected = selected.decremented()
//        refersToQuestion = selected.refersToQuestion
        switch selected {
        case .landing: reconcileBoolState(bySetting: .landing)
        case .presenting(_): reconcileBoolState(bySetting: .question)
        case .completion: reconcileBoolState(bySetting: .completed)
        case .none:
            reconcileBoolState(bySetting: .NONE)
        }
    }

    var questionIdentifier: Int? {
        guard let containedID = selected.questionIdentifier else {
//            return nil
            preconditionFailure(
                "selected wasn't a .presenting.")
        }
        return containedID
    }
}


