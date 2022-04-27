//
//  SurveyCompleteView.swift
//  Async Accel
//
//  Created by Fritz Anderson on 4/5/22.
//

import SwiftUI

#warning("Remove SubjectIDDependent and other mass-deletions.")
protocol SubjectIDDependent {
    @discardableResult
    func teardownFromSubjectID() async throws -> Self?
    func setUpWithSubjectID(_ newID: String) async throws -> Self?
}



fileprivate let completionText = """
You have completed the survey portion of this exercise.
"""

fileprivate let startIncompleteText = """

NOTE: You still have
"""
fileprivate let endIncompleteText = """
 questions yet to answer.
"""


// FIXME: Environment-ize shared state for all finished
//        AppStageState.shared.allTasksFinished
struct SurveyCompleteView: View {
    @EnvironmentObject var pages    : DASIPages
    @EnvironmentObject var responses: DASIResponseList
    @EnvironmentObject var subjectIDObject: SubjectID
    @EnvironmentObject var phaseManager: PhaseManager

    var allItemsAnswered: Bool {
        return responses.unknownResponseIDs.isEmpty
    }

    var instructions: String {
        var retval = completionText + nextSteps
        if !allItemsAnswered {
            let empties = responses.unknownResponseIDs
            retval += startIncompleteText + "\(empties.count)" + endIncompleteText
        }
        return retval
    }

    var body: some View {
        VStack {
            ForwardBackBar(forward: false, back: true, action: { _ in
                pages.decrement()
            })
                .frame(height: 44)
            Spacer()
            GenericInstructionView(
                titleText: "Survey Complete",
                bodyText: instructions, // + completionText,
                sfBadgeName: "checkmark.square")
            .padding()
        }
        .navigationBarHidden(true)
        .onAppear{
            // IF ALL ARE ANSWERED
            if allItemsAnswered {
                AppStage.shared
                    .completionSet
                    .insert(.dasi)
                // TODO: Maybe create the report data on completionSet changing.
            }
        }
    }

    var nextSteps: String {
        if phaseManager.allTasksFinished {
            return "\nPlease proceed to the “Report” view to submit your information to the team."
        }
        else {
            return "\nNow select the “Walk” tab below to proceed to the walking portion of the exercise."
        }
    }
}

struct SurveyCompleteView_Previews: PreviewProvider {
    static var previews: some View {
        SurveyCompleteView()
            .environmentObject(DASIPages())
            .environmentObject(DASIResponseList())
            .environmentObject(SubjectID())
            .environmentObject(PhaseManager())
    }
}
