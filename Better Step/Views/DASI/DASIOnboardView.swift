//
//  DASIOnboardView.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/7/22.
//

import SwiftUI

/// The first user-visible display in the DASI phase.
///
/// The ``SuccessValue`` as a ``ReportingPhase`` is `Void`.
struct DASIOnboardView: View, ReportingPhase {
    typealias SuccessValue = ()
    let completion: ClosureType

    static let instructions = """
In this part of the assessment, you will be asked \(DASIQuestion.count) questions about how well you do with various activities.

Answer “Yes” or “No” to each. You will be able to move backward and forward through the questions, but you must respond to all for this exercise to be complete.
"""

    init(completion: @escaping ClosureType) {
        self.completion = completion
    }

    // TODO: Add the forward/back bar.

    var body: some View {
        VStack {
            Spacer()
            GenericInstructionView(
                titleText: "Activity Survey",
                upperText: Self.instructions,
                sfBadgeName: "checkmark.square",
                lowerText: Self.instructions,
                proceedTitle: "Continue",
                proceedEnabled: true) {
#warning("Configure DASIOnboard with .json")
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
        }
    }
