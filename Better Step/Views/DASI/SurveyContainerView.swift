//
//  SurveyContainerView.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/7/22.
//

import SwiftUI
import Combine


// TODO: remove the slide-from-leading animation
//       or make it conistent with the Other animation
//       (Correctly or not this was attached to Usability container.)


enum DASIState {
    case landing, question, completed, NONE
}

/// A container for the DASI workflow: Intro screen, questions, and final screen.
///
/// The ``SuccessValue`` as a ``ReportingPhase`` is ``DASIResponseList``.
struct SurveyContainerView: View, ReportingPhase {
    // TODO: Query whether SurveyContainerView needs to be a ReportingPhase.
    typealias SuccessValue = DASIResponseList
    let completion: ClosureType

    @State          var dasiPhaseState: DASIState? = .landing
    @StateObject    var responses = DASIResponseList()
    @AppStorage(ASKeys.temporaryDASIResults.rawValue) var tempCSV: String = ""

//    var notificationHandler: NSObjectProtocol?
    // I DON'T THINK THIS LAYER NEED DO ANYTHING WITH
    // DATA DESTRUCTION. Any that still has to be done is
    // done in PhaseStorage.

    init(phase: DASIState = .landing,
         closure: @escaping ClosureType) {
        dasiPhaseState = phase
        completion = closure
    }

    var body: some View {
        VStack {
            switch dasiPhaseState! {
            case .landing:
                landingPageView()

            case .question:
                questionPageView()

            case .completed:
                completionPageView()
                // Completion calls my response closure

            case .NONE:
                fatalError("Unassigned phase in \(#function)")
            }
        }
        .environmentObject(responses)
    }
}

struct SurveyContainerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SurveyContainerView(closure: {
                result in
                print("Result:", result)
            })
        }
        NavigationView {
            SurveyContainerView(
                phase: .question,
                closure: {
                    result in
                    print("Result:", result)
                })
        }
        NavigationView {
            SurveyContainerView(
                phase: .completed,
                closure: {
                    result in
                    print("Result:", result)
                })
        }

//        .environmentObject(DASIResponseList())
    }
}
