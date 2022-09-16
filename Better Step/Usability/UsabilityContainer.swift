//
//  UsabilityContainer.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/12/22.
//

import SwiftUI

// TODO: Present the questions as a page-mode Picker.

/// A  sequence of open-intertitial → questions → close-interstitial phases
///
/// The ``UsabilityController`` takes care of navigating among the phases and
/// the usability questions, including recording the responses.
struct UsabilityContainer: View {
    // FIXME: Conform UsabilityContainer to own, not envt, its controller.
    @EnvironmentObject var controller: UsabilityController

    var body: some View {
        List {
            questionPresentationView()
            openingInterstitialView()
            closingInterstitialView()
        }
    }

    // MARK: - Links to phase views

    // MARK: Question
    func questionPresentationView() -> some View {
        NavigationLink("",
                       tag: UsabilityPhase.questions,
                       selection: $controller.currentPhase) {
            UsabilityView(
                questionID: controller.questionID,
                selectedAnswer: $controller.currentResponse)
            { newAnswer in
                controller.increment()
            }   // Questions destination
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("← Back") { controller.decrement() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Next →") { controller.increment() }
                }
            }

            .navigationBarBackButtonHidden(true)
        }
    }

    // TODO: Re-entry; incomplete answers.
    //       Shouldn't dump into the opening again, should it?
    // It's probably good-enough, one of the purposes of G-Bars is to be pre-integration.

    // MARK: Opening
    func openingInterstitialView() -> some View {
        NavigationLink("", tag: UsabilityPhase.start, selection: $controller.currentPhase) {
            UsabilityInterstitialView(
                titleText: "Usability",
                bodyText: usabilityInCopy, //"This space for rent",
                systemImageName: "checkmark.circle",
                continueTitle: "Continue", completion: {})
            .navigationBarBackButtonHidden(true)
        }
    }

    // MARK: Closing
    func closingInterstitialView() -> some View {
        NavigationLink("", tag: UsabilityPhase.end, selection: $controller.currentPhase) {
            UsabilityInterstitialView(
                titleText: "Completed",
                bodyText: usabilityOutCopy,
                systemImageName: "checkmark.circle",
                continueTitle: "Continue") {


// CALL BACK to the walking container
// to signal a phase transition.


                }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("← Back") { controller.decrement() }
                }
            }
        }
    }
}

// MARK: - Previews
struct UsabilityContainer_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UsabilityContainer()
        }
        .environmentObject(UsabilityController(phase: .start, questionID: 1))
        .environmentObject(DASIPages())
        .previewDevice(.init(stringLiteral: "iPhone 12"))
        .previewDevice(.init(stringLiteral: "iPhone SE (3rd generation)"))
    }
}
