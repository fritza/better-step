//
//  UsabilityContainer.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/12/22.
//

import SwiftUI

#warning("Access to State outside View?")
/*
 2022-10-26 10:24:45.053459-0500 Better Step[96717:948341] [SwiftUI] Accessing State's value outside of being installed on a View. This will result in a constant Binding of the initial value and will not update.
 */

enum UsabilityState: Int, CaseIterable {
    case intro, questions
#if INCLUDE_USABILITY_SUMMARY
    case report
#endif
    case closing

    static let csvPrefix = "PSSUQ"
}


/// A  sequence of open-intertitial → questions → close-interstitial phases. Each solicits a `1...7` rating.
///
/// Its `SuccessValue` as a ``ReportingPhase`` is `String`, a CSV line of responses to the 1–7 ratings.
struct UsabilityContainer: View, ReportingPhase {
    typealias SuccessValue = String
    let completion: ClosureType
    #warning("UsabilityContainer does not complete.")
    @AppStorage(AppStorageKeys.tempUsabilityIntsCSV.rawValue)
    var tempCSV: String = ""

    @State var currentState: UsabilityState
    @State var recommendedPostReset: Int?
    @State var shouldDisplayReversionAlert = false

    // Holder for the block that handles Destroy.usability.
    private var notificationHandler: NSObjectProtocol?



    init(state: UsabilityState = .intro,
         //         questionIndex: Int = 0,
         result: @escaping ClosureType) {
        self.completion = result
        self.currentState = state
        notificationHandler = registerDataDeletion()
    }

    var body: some View {
        Group {
            switch currentState {
            case .intro:
                GenericInstructionView(
                    titleText: "Usability",
                    bodyText: usabilityInCopy,
                    sfBadgeName: "person.crop.circle.badge.questionmark",
                    proceedTitle: "Continue",
                    proceedEnabled: true) {
                        currentState = .questions
                    }

            case .questions :                 UsabilityView(questionIndex: 0) { resultValue in
                guard let array = try? resultValue.get() else {
                    print("UsabilityView should not fail.")
                    fatalError()
                }
                tempCSV = array.csvLine
                if array.allSatisfy({ $0 != 0 }) {
                    currentState = .closing
                }
            }

            case .closing   :
                // TODO: Remove UsabilityInterstitialView.
                UsabilityInterstitialView(
                    titleText: "Completed",
                    bodyText: usabilityOutCopy,
                    systemImageName: "checkmark.circle",
                    continueTitle: "Continue", completion: {
                        _ in  completion(.success("???"))
                    })

            default: Text("Can't happen.")
            }   // switch
        }
        // Group
        .reversionAlert(on: $shouldDisplayReversionAlert)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ReversionButton(toBeSet: $shouldDisplayReversionAlert)
            }
        }   // toolbar
        .navigationBarBackButtonHidden(true)
    }       // body

    // MARK: - Links to phase views

    // MARK: Question
    // FIXME: This isn't a @ViewBuilder?!

    private var responses = [Int](repeating: 0, count: UsabilityQuestion.count)
    var csvLine: String {
        return "\(UsabilityState.csvPrefix),\(SubjectID.id)," + responses.csvLine
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
