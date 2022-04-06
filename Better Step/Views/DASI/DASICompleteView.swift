//
//  DASICompleteView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/28/22.
//

import SwiftUI

fileprivate let completionText = """
You have completed the survey portion of this exercise.
"""

fileprivate let startIncompleteText = """

NOTE: You still have
"""
fileprivate let endIncompleteText = """
 questions yet to answer.
"""

fileprivate var nextSteps: String {
    if PhaseManager.shared.allTasksFinished {
        return "\nPlease proceed to the “Report” view to submit your information to the team."
    }
    else {
        return "\nNow select the “Walk” tab below to proceed to the walking portion of the exercise."
    }
}

//let nextSteps = "NON-GLOBAL nextSteps"

// FIXME: Should there be a Back button?

struct DASICompleteView: View {
    @EnvironmentObject private var responses: DASIResponseList
    @EnvironmentObject private var questions: DASIPages
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
                questions.decrement()
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
}

struct DASICompleteView_Previews: PreviewProvider {
    static var previews: some View {
        DASICompleteView()
            .environmentObject(DASIPages())
    }
}
