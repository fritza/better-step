//
//  UsabilityContainer.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/12/22.
//

import SwiftUI

// TODO: Present the questions as a page-mode Picker.
#warning("Untangle the question paging from usability phase nav")

/// A  sequence of open-intertitial → questions → close-interstitial phases
///
/// The ``UsabilityPageSelection`` takes care of navigating among the phases and
/// the usability questions, including recording the responses.
struct UsabilityContainer: View, ReportingPhase {
    typealias SuccessValue = String
    let completion: ClosureType
    init(_ result: @escaping ClosureType) {
        pageNumber = 1
        self.completion = result
    }

    @State var pageNumber: Int
    @StateObject var pageSelection = UsabilityPageSelection(phase: .start, questionID: 1)
    // Sets selection to .start, question 1.

    @State var recommendedPostReset: Int?

    var body: some View {
        List {
            questionPresentationView()
            // UsabilityView
            openingInterstitialView()
            // UsabilityInterstitialView "Usability"
#if INCLUDE_USABILITY_SUMMARY
            usabilitySummaryView()
#endif
            closingInterstitialView()
//            UsabilityInterstitialView "Completed"
        }
        .reversionAlert(next: $recommendedPostReset,
                        shouldShow:
                            ResetStatus.shared.$resetAlertVisible)
    }

    // MARK: - Links to phase views

    // MARK: Question
    // FIXME: This isn't a @ViewBuilder?!
    @ViewBuilder
    func questionPresentationView() -> some View {
        NavigationLink("",
                       tag: UsabilityPhase.questions,
                       selection: $pageSelection.currentPhase) {
            UsabilityView(


                // FIXME: Handle the question indexing.


                questionID: pageSelection.questionID,
                selectedAnswer: $pageSelection.currentResponse)
            { newAnswer in

#warning("Distinguish Usability increment from usability ended")

                pageSelection.increment()
            }   // Questions destination

            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("← Back") {
                        if pageNumber > 1 {
                            pageNumber -= 1
                        }
                        pageSelection.decrement() }
                }

                ToolbarItemGroup(placement: .navigationBarTrailing) {
//                    ReversionButton(
//                        shouldShow: ResetStatus
//                            .shared
//                            .$resetAlertVisible
//                    )
                    Button("Next →") {
                        if pageNumber < UsabilityQuestion.count {
                            pageNumber += 1
                        }
                        pageSelection.increment()
                    }
                }
            })
            /*
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("← Back") {
                        if pageNumber > 1 {
                            pageNumber -= 1
                        }
                        pageSelection.decrement() }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    ReversionButton(shouldShow: ResetStatus.shared.$resetAlertVisible)
                    Button("Next →") {
                        if pageNumber < UsabilityQuestion.count {
                            pageNumber += 1
                        }
                        pageSelection.increment()
                    }
                }
            }
             */
            .environmentObject(pageSelection)
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
                continueTitle: "Continue",
                completion: { _ in  })
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ReversionButton(shouldShow: ResetStatus.shared.$resetAlertVisible)
                    }
                }
            .environmentObject(pageSelection)
            .navigationBarBackButtonHidden(true)
        }
    }

    // MARK: Closing
    func closingInterstitialView() -> some View {
        NavigationLink("", tag: UsabilityPhase.end,
                       selection: $pageSelection.currentPhase) {
            UsabilityInterstitialView(
                titleText: "Completed",
                bodyText: usabilityOutCopy,
                systemImageName: "checkmark.circle",
                continueTitle: "Continue", completion: {
                    _ in  completion(.success("???"))
                })
            .navigationBarBackButtonHidden(true)

            // NOTE: Expected String
            //       as the success value of
            //       UsabilityInterstitialView.
            //       (is Void)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("← Back") { pageSelection.decrement() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    ReversionButton(
                        shouldShow: ResetStatus.shared
                            .$resetAlertVisible)
                }
            }
        }
        .environmentObject(pageSelection)
    }

#if INCLUDE_USABILITY_SUMMARY
    // MARK: Summary (optional, debug-only)
    func usabilitySummaryView() -> some View {
        NavigationLink("", tag: UsabilityPhase.summary, selection: $pageSelection.currentPhase) {
            UsabilitySummaryView {
                _ in

                print("Usability Summary completed.")
                // FIXME: Untangle container phase from sequence phase.

            }
            .navigationBarBackButtonHidden(true)

            // NOTE: Expected String
            //       as the success value of
            //       UsabilityInterstitialView.
            //       (is Void)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("← Back") { pageSelection.decrement() }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                ReversionButton(shouldShow: ResetStatus.shared.$resetAlertVisible)
            }
            .environmentObject(pageSelection)
        }
        }
#endif
}

// MARK: - Previews
struct UsabilityContainer_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UsabilityContainer() { _ in }
        }
        .environmentObject(UsabilityPageSelection(phase: .start, questionID: 1))
        .previewDevice(.init(stringLiteral: "iPhone 12"))
        .previewDevice(.init(stringLiteral: "iPhone SE (3rd generation)"))
    }
}
