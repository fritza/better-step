//
//  UsabilityController.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/11/22.
//

import Foundation

// TODO: Amend to conform to the container-management scheme in Better Step.

/// The general state of presentation.
///
/// - `start`: opening interstitial
/// - `questions`: the sequence of questions
/// - `end`: the final interstitial
/// - `summary` (demo only): display the responses to all questions.
/// - note: ``UsabilityController`` is the type that does incrementing and decrementing. It _could_ be amended to take advantage of `UsabilityPhase`'s being `AppStages`, but it's not plug-and-play.
enum UsabilityPhase: // AppStages,
                        CaseIterable, Comparable
    //CaseIterable, Comparable, Hashable
{
    case start, questions, end, summary
    var csvPrefix: String? { "PSSUQ" }
}


/// Observable owner of the state of the usability workflow, including opening and closing interstitials.
///
/// ``UsabilityContainer`` and ``UsabilityView`` are clients.
final class UsabilityController: ObservableObject {

    /// DRY for moving the displayed choice to the persistent record.
    func storeCurrentResponse() {
        results[questionID-1] = currentResponse
    }

    /// The phase (start, questions, end) currently displayed.
    @Published var currentPhase: UsabilityPhase! = .start {
        willSet {
            if newValue != currentPhase && currentPhase == .questions {
                storeCurrentResponse()
            }
        }
    }

    /// The ID (not index) of the question currently displayed.
    ///
    /// Assignment stores the current response and loads up the response to the newly presented questions.
    @Published var questionID = 1 {
        willSet {
            storeCurrentResponse()
        }
        didSet {
            currentResponse = results[questionID-1]
        }
    }

    /// The answer (1–7) for the current question. Initialized to zero (illegal)
    @Published var currentResponse = 0

    // TODO: Validate the question index.

    /// The question currently displayed.
    var currentQuestion: UsabilityQuestion? {
        // Subscript on UsabilityQuestion addresses the ID, not the index in storage.
        return UsabilityQuestion[questionID]
    }

    /// Is there a question after the current one?
    var canIncrement: Bool { currentPhase < .end }
    /// Shift focus to the question after the current one.
    /// - precondition: The current question is the last.
    func increment() {
        switch currentPhase {
        case .start: currentPhase = .questions; questionID = 1
        case .end  : preconditionFailure("Attempt to increment beyond end")
        case .questions where questionID >= UsabilityQuestion.endID-1:
            currentPhase = .end
        default:
            questionID += 1
        }
    }

    /// Is there a question before the current one?
    var canDecrement: Bool { currentPhase > .start }
    /// Shift focus to the question before the current one.
    /// - precondition: The current question is the first.
    func decrement() {
        switch currentPhase {
        case .start: preconditionFailure("Attempt to decrement beyond start")
        case .end  : currentPhase = .questions; questionID = UsabilityQuestion.endID - 1
        case .questions where questionID <= 1:
            currentPhase = .start
        default:
            questionID -= 1
        }
    }

    /// All responses, initialized to all-zeroes (unanswered).
    var results =  [Int](repeating: 0, count: UsabilityQuestion.count)

    // Start without interstitials.
    /// Set up the questions and display one.
    /// - parameters:
    ///     - phase: The portion (open/questions/close) to display. Defaults to the opening interstitial.
    ///     - questionID: The ID (_not_ index) of the question to present. This persists even if the current phase is not .questions. Optional; default is the first question.
    init(phase: UsabilityPhase = .start, questionID: Int = 1) {
        currentPhase = phase
        self.questionID = questionID
        currentResponse = results[questionID-1]
    }
}
