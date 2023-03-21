//
//  UsabilityContainer.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/12/22.
//

import SwiftUI
import Combine
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

// MARK: - UsabilityContainer
/// A  sequence of open-intertitial → questions → close-interstitial phases. Each solicits a `1...7` rating.
///
/// Its ``SuccessValue`` as a ``ReportingPhase`` is `(scores: String, specifics: String)`, a CSV line of responses to the 1–7 ratings.
/// - note: This view contains ``UsabilityView``, ``WalkUsabilityForm``, and ``UsabilityInterstitialView``. It is ultimately contained in a `NavigationView` in ``TopContainerView``.

struct UsabilityContainer: View, ReportingPhase {
    // NOTE: This element is contained in a `NavigationView` within ``TopContainerView``.
    
    typealias SuccessValue = String
    let completion: ClosureType
    @AppStorage(ASKeys.tempUsabilityIntsCSV.rawValue)
    /// Return CSV value for reporting success.
    var tempCSV: String = ""
    static private var cancellables: [AnyCancellable] = []

    /// Top-level-in-usability phase `intro`, `questions`, (`report`), `closing`
    @State var currentState: UsabilityState    
    /// Whether the "reversion" (back to beginning with no subject) dialog should be shown.
    ///
    /// See ``reversionAlert(on:)`` for the `ViewModifier`.

    init(state: UsabilityState = .intro,
         result: @escaping ClosureType) {
        self.completion = result
        self.currentState = state
        setUpCombine()
    }
    
    @State var multipleChoices: [Int] = []
    @State var fullUsabilityCSV = ""
    
    let firstContent = CardContent(pageTitle: "Usability"
                                   , contentBelow: usabilityInCopy,
                                   contentAbove: "", systemImage: "person.crop.circle.badge.questionmark", imageFileName: nil, proceedTitle: "Continue")

    var body: some View {
        VStack {
            switch currentState {
                // MARK: - Intro
            case .intro:
                /*
                GenericInstructionView(
                    titleText: "Usability",
                    sfBadgeName: "person.crop.circle.badge.questionmark",
                    lowerText: usabilityInCopy,
                    proceedTitle: "Continue",
                    proceedEnabled: true) {
                        currentState = .questions
                    }
                 */
                SimplestCard(content: firstContent) {
                    currentState = .questions
                }
                .padding()
                
                // MARK: - Questions
            case .questions :
                // resultValue is Result<[Int], Never>




                // FIXME: <Back crashes UsabilityView.
                // In the preview of the UsabilityContainer

                
                
                
                UsabilityView(questionIndex: 0) { resultValue in
                    guard let array = try? resultValue.get() else {
                        print("UsabilityView should not fail.")
                        fatalError()
                    }
                    
                    multipleChoices = array
                    currentState = .surveyForm
                }
                
                // MARK: - survey form
            case .surveyForm:
                WalkUsabilityForm {
                    result in
                    assert(SubjectID.isSet)
                    
                    // result is Result<String, Never>
                    let infoResult = try! result.get()
                    
                    let prefix = "\(SeriesTag.usability.rawValue),\(SubjectID.id),\(Date().ymd),"
                    let choiceSection = multipleChoices.csvLine + ","
                    
                    fullUsabilityCSV = prefix + choiceSection + infoResult
                    currentState = .closing
                }
                
                // MARK: - Closing
            case .closing   :
                // TODO: Remove UsabilityInterstitialView.
                UsabilityInterstitialView(
                    titleText: "Completed",
                    bodyText: usabilityOutCopy,
                    systemImageName: "checkmark.circle",
                    continueTitle: "Continue") {
                        _ in
                        // Incoming us just an ()
                        completion(
                            .success(fullUsabilityCSV)
                        )
                        let data = fullUsabilityCSV.data(using: .utf8)
                        try! PhaseStorage.shared.series(.usability, completedWith: data!)
                    }
            }       // switch?
        }           // VStack
        .navigationBarBackButtonHidden(true)
}       // body

    // MARK: - Links to phase views
    private var responses = [Int](repeating: 0,
                                  count: UsabilityQuestion.count)
    public var csvLine: String {
        assert(SubjectID.isSet)
        return "\(SeriesTag.usability.rawValue),\(SubjectID.id),\(responses.csvLine)"
    }
}

extension UsabilityContainer {
    func setUpCombine() {
        revertAllNotification
            .sink { _ in tempCSV = "" }
            .store(in: &Self.cancellables)
    }
}

// MARK: - Previews
struct UsabilityContainer_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UsabilityContainer() { _ in }
        }
        .previewDevice(.init(stringLiteral: "iPhone 12"))
        .previewDevice(.init(stringLiteral: "iPhone Xs"))
    }
}
