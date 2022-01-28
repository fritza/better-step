//
//  DASICompleteView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/28/22.
//

import SwiftUI

fileprivate let completionText = """
BUG: Need a Back button and condition on the status

You have completed the survey portion of this exercise.
"""

fileprivate var nextSteps: String {
    if GlobalState.readyToReport {
        return "\nPlease proceed to the “Report” view to submit your information to the team."
    }
    else {
        return "\nNow select the “Walk” tab below to proceed to the walking portion of the exercise."
    }
}

// FIXME: - Make the instructions dynamic
//          depending on whether all parts have completed.
// FIXME: Should there be a Back button?

struct DASICompleteView: View {
    var instructions: String {
        completionText + nextSteps
    }


    var body: some View {
        NavigationView {
            GenericInstructionView(
                titleText: "Survey Complete",
                bodyText: instructions, // + completionText,
                sfBadgeName: "checkmark.square")
        }
        .onAppear{
            GlobalState.dasi.complete()
        }
    }
}

struct DASICompleteView_Previews: PreviewProvider {
    static var previews: some View {
        DASICompleteView()
    }
}
