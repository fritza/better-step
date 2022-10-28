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


/// A  sequence of open-intertitial → questions → close-interstitial phases
struct UsabilityContainer: View, ReportingPhase {
    typealias SuccessValue = String
    let completion: ClosureType
    @AppStorage(AppStorageKeys.tempUsabilityIntsCSV.rawValue)
    var tempCSV: String = ""

    @State var currentState: UsabilityState
    @State var recommendedPostReset: Int?
    @State var shouldDisplayReversionAlert = false
    @StateObject var shouldDisplay = ResetStatus()

    init(state: UsabilityState = .intro,
         //         questionIndex: Int = 0,
         result: @escaping ClosureType) {
        self.completion = result
        self.currentState = state
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


        .environmentObject(shouldDisplay)

        #if false
        .reversionAlert(on: $shouldDisplay.resetAlertVisible)
//        .reversionAlert(on: $shouldDisplay)
        #else
        .alert("Starting Over",
               isPresented:
                $shouldDisplay.resetAlertVisible
//               ResetStatus.shared.resetAlertVisible
        ) {

            Button("First Run" , role: .destructive) {
                Destroy.dataForSubject.post()
            }

            Button("Cancel", role: .cancel) {
                //                    shouldShow = false
            }
        }
    message: {
        Text("Do you want to revert to the first run and collect subject ID, surveys, and walks?\nYou cannot undo this.")
    }
        #endif

    .navigationBarBackButtonHidden(true)
        //        .environment(\.symbolRenderingMode, .hierarchical)
        //        .symbolRenderingMode(.hierarchical)

    }       // body

    // MARK: - Links to phase views

    // MARK: Question
    // FIXME: This isn't a @ViewBuilder?!

    private var responses = [Int](repeating: 0, count: UsabilityQuestion.count)
    var csvLine: String {
        return "\(UsabilityState.csvPrefix),\(SubjectID.id)," + responses.csvLine
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
