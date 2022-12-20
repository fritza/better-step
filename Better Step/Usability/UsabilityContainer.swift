//
//  UsabilityContainer.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/12/22.
//

import SwiftUI

/*
 2022-10-26 10:24:45.053459-0500 Better Step[96717:948341] [SwiftUI] Accessing State's value outside of being installed on a View. This will result in a constant Binding of the initial value and will not update.
 */

enum UsabilityState: Int, CaseIterable {
    case intro, questions
#if INCLUDE_USABILITY_SUMMARY
    case report
#endif
    case surveyForm
    case closing
}


/// A  sequence of open-intertitial → questions → close-interstitial phases. Each solicits a `1...7` rating.
///
/// Its ``SuccessValue`` as a ``ReportingPhase`` is `(scores: String, specifics: String)`, a CSV line of responses to the 1–7 ratings.
struct UsabilityContainer: View, ReportingPhase {
// FIXME: The second, "specifics" SuccessValue isn't used.

    typealias SuccessValue = (scores: String, specifics: String)
    let completion: ClosureType
    @AppStorage(ASKeys.tempUsabilityIntsCSV.rawValue)
    /// Return CSV value for reporting success.
    var tempCSV: String = ""

    /// Top-level-in-usability phase `intro`, `questions`, (`report`), `closing`
    @State var currentState: UsabilityState
    /// Whether the "reversion" (back to beginning with no subject) dialog should be shown.
    ///
    /// See ``reversionAlert(on:)`` for the `ViewModifier`.
    @State var shouldDisplayReversionAlert = false

    /// Holder for the block that handles Destroy.usability.
    private var notificationHandler: NSObjectProtocol?


    init(state: UsabilityState = .intro,
         result: @escaping ClosureType) {
        self.completion = result
        self.currentState = state
        notificationHandler = registerDataDeletion()
    }

    var body: some View {
        VStack {
            switch currentState {
                // MARK: Intro
            case .intro:
                GenericInstructionView(
                    titleText: "Usability",
                    bodyText: usabilityInCopy,
                    sfBadgeName: "person.crop.circle.badge.questionmark",
                    proceedTitle: "Continue",
                    proceedEnabled: true) {
                        currentState = .questions
                    }

            case .questions :
                UsabilityView(questionIndex: 0) { resultValue in
                guard let array = try? resultValue.get() else {
                    print("UsabilityView should not fail.")
                    fatalError()
                }
                tempCSV = array.csvLine
                if array.allSatisfy({ $0 != 0 }) {
                    currentState = .closing
                }
                    
                    
                    
                    
                    
                    
                    
                    
                    
            }


                // FIXME: Add a survey container.
            case .surveyForm,
                    .closing   :
                // TODO: Remove UsabilityInterstitialView.
                UsabilityInterstitialView(
                    titleText: "Completed",
                    bodyText: usabilityOutCopy,
                    systemImageName: "checkmark.circle",
                    continueTitle: "Continue",
                    completion: {
                        _ in
                        completion(
                            .success(
                                (scores: tempCSV,
                                 specifics: "")
                            )
                        )
                    })
            }
        }  // VStack
        .reversionAlert(on: $shouldDisplayReversionAlert)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ReversionButton(toBeSet: $shouldDisplayReversionAlert)
            }
        }   // toolbar
        .navigationBarBackButtonHidden(true)
    }       // body

    // MARK: - Links to phase views
    private var responses = [Int](repeating: 0,
                                  count: UsabilityQuestion.count)
    public var csvLine: String {
        return "\(SeriesTag.usability.rawValue),\(SubjectID.id),\(responses.csvLine)"
    }
}

extension UsabilityContainer {
    func registerDataDeletion() -> NSObjectProtocol {
        let dCenter = NotificationCenter.default

        // TODO: Should I set hasCompletedSurveys if the walk is negated?
        let catcher = dCenter
            .addObserver(
                forName: Destroy.usability.notificationID,
                object: nil,
                queue: .current)
        { _ in
            // WARNING: TEMPORARY, using AppStorage for the completed survey.
            tempCSV = ""
        }
        return catcher
    }
}

// MARK: - Previews
struct UsabilityContainer_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UsabilityContainer() { _ in }
        }
        .previewDevice(.init(stringLiteral: "iPhone 12"))
        .previewDevice(.init(stringLiteral: "iPhone SE (3rd generation)"))
    }
}
