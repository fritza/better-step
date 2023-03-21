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

    init(_ closure: @escaping ClosureType) {
        completion = closure
//        notificationHandler = registerDataDeletion()
    }

    

    // MARK: - Destruction

/*
    func registerDataDeletion()
    -> NSObjectProtocol {

        // FIXME: Substitute wiping the file.
        //        How in general do you wipe out stage files?
        
        let dCenter = NotificationCenter.default

        // TODO: Should I set hasCompletedSurveys if the walk is negated?
        let catcher = dCenter
            .addObserver(
                forName: Destroy.DASI.notificationID,
                object: nil,
                queue: .current) {
                    _ in tempCSV = ""
                }
        return catcher
    }
*/


    // FIXME: YUCK! if this doesn't easily work…
    // Oh gosh — what would I have to do to make it a navigable view like the top level?
    // Given that there are no optional branches, maybe there is simply no need.

    var body: some View {
        switch dasiPhaseState! {
        case .landing:
            landingPageView()

        case .question:
            questionPageView()

        case .completed:
            // FIXME: Consider storing the DASI response here.
            // instead of the top container.
            completionPageView()
            // Completion calls my response closure

        case .NONE:
            fatalError("Unassigned phase in \(#function)")
        }
    }
}

struct SurveyContainerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SurveyContainerView({
                result in
                print("Result:", result)
            })
        }
        .environmentObject(DASIResponseList())
    }
}
