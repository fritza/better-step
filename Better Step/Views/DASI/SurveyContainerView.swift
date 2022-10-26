//
//  SurveyContainerView.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/7/22.
//

import SwiftUI
import Combine


enum DASIState {
    case landing, question, completed, NONE
}

struct SurveyContainerView: View, ReportingPhase {
    // TODO: Query whether SurveyContainerView needs to be a ReportingPhase.
    typealias SuccessValue = DASIResponseList
    let completion: ClosureType

    @State          var dasiPhaseState: DASIState? = .landing
    @StateObject    var responses = DASIResponseList()
    @AppStorage(AppStorageKeys.temporaryDASIResults.rawValue) var csvStash: String = ""


    init(_ closure: @escaping ClosureType) {
        completion = closure
    }

#warning("Be sure to initialize Pages and Response list")
//    @StateObject    var pager     = DASIPageSelection(.landing)

    // FIXME: YUCK! if this doesn't easily work…
    // Oh gosh — what would I have to do to make it a navigable view like the top level?
    // Given that there are no optional branches, maybe there is simply no need.

    var body: some View {
        VStack {
            Text(
                "SHOULD NOT APPEAR"
            )



            // MARK: Landing page
            landingPageView()
            // MARK: Complete page
            completionPageView()
            // MARK: Question pages
            questionPageView()
        }
//        .environmentObject(self.pager)
        .environmentObject(self.responses)
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
//        .environmentObject(DASIPageSelection(.landing))
        .environmentObject(DASIResponseList())
    }
}
