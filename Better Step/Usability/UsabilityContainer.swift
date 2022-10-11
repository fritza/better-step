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
/// The ``UsabilityPageSelection`` takes care of navigating among the phases and
/// the usability questions, including recording the responses.
struct UsabilityContainer: View, ReportingPhase {
    let completion: ((Result<String, Error>) -> Void)!


    // FIXME: Conform UsabilityContainer to own, not envt, its pageSelection.
    @StateObject var pageSelection = UsabilityPageSelection()
    // Sets selection to .start, question 1.

    var body: some View {
        List {
            questionPresentationView()
            openingInterstitialView()
            closingInterstitialView()
        }
        .environmentObject(pageSelection)
    }

    // MARK: - Links to phase views

    // MARK: Question
    func questionPresentationView() -> some View {
        NavigationLink("",
                       tag: UsabilityPhase.questions,
                       selection: $pageSelection.currentPhase) {
            UsabilityView(
                questionID: pageSelection.questionID,
                selectedAnswer: $pageSelection.currentResponse)
            { newAnswer in
                pageSelection.increment()
            }   // Questions destination
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("← Back") { pageSelection.decrement() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Next →") { pageSelection.increment() }
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
        NavigationLink("", tag: UsabilityPhase.start, selection: $pageSelection.currentPhase) {
            UsabilityInterstitialView(
                titleText: "Usability",
                bodyText: usabilityInCopy, //"This space for rent",
                systemImageName: "checkmark.circle",
                continueTitle: "Continue", completion: {_ in})
            .navigationBarBackButtonHidden(true)
        }
    }

    // MARK: Closing
    func closingInterstitialView() -> some View {
        NavigationLink("", tag: UsabilityPhase.end, selection: $pageSelection.currentPhase) {
            UsabilityInterstitialView(
                titleText: "Completed",
                bodyText: usabilityOutCopy,
                systemImageName: "checkmark.circle",
                continueTitle: "Continue") { response in
                    guard let numbers = try? response.get() else {
                        completion(.failure(AppPhaseErrors.NOS)); return
                    }
                    completion(.success(numbers.csvLine))
                }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("← Back") { pageSelection.decrement() }
                }
            }
        }
    }
}

// MARK: - Previews
struct UsabilityContainer_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UsabilityContainer() { _ in }
        }
        .environmentObject(UsabilityPageSelection(phase: .start, questionID: 1))
//        .environmentObject(DASIPageSelection())
        .previewDevice(.init(stringLiteral: "iPhone 12"))
        .previewDevice(.init(stringLiteral: "iPhone SE (3rd generation)"))
    }
}
