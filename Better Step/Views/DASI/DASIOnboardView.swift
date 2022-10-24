//
//  DASIOnboardView.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/7/22.
//

import SwiftUI

struct DASIOnboardView: View, ReportingPhase {
    typealias SuccessValue = ()
    let completion: ClosureType

    static let instructions = """
In this part of the assessment, you will be asked \(DASIQuestion.count) questions about how well you do with various activities.

Answer “Yes” or “No” to each. You will be able to move backward and forward through the questions, but you must respond to all for this exercise to be complete.
"""

//    @EnvironmentObject var pager: DASIPageSelection
    init(completion: @escaping ClosureType) {
        self.completion = completion
    }

    // TODO: Add the forward/back bar.

    var body: some View {
        VStack {
            Spacer()
            GenericInstructionView(
                titleText: "Activity Survey",
                bodyText: Self.instructions,
                sfBadgeName: "checkmark.square",
                proceedTitle: "Continue",
                proceedEnabled: true) {
                    completion(.success(()))
//                    self.pager.pagerState = .question
                }
                .padding()
                .navigationBarHidden(true)
        }
        .onAppear{
        }
    }
}

    struct DASIOnboardView_Previews: PreviewProvider {
        static var previews: some View {
            DASIOnboardView(completion: { _ in })
//                .environmentObject(DASIPageSelection(.landing))
        }
    }
