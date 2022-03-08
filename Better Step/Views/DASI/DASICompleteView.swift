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
    if GlobalState.current.allTasksFinished {
        return "\nPlease proceed to the “Report” view to submit your information to the team."
    }
    else {
        return "\nNow select the “Walk” tab below to proceed to the walking portion of the exercise."
    }
}

//let nextSteps = "NON-GLOBAL nextSteps"

// FIXME: Should there be a Back button?

struct DASICompleteView: View {
    @EnvironmentObject private var globalState: GlobalState
    @EnvironmentObject var envt: DASIContentState


    var instructions: String {
        completionText + nextSteps
    }

    var body: some View {
//        NavigationView {
            VStack {
                ForwardBackBar(forward: false, back: true, action: { _ in
                    // expr envt.selected ?? "NO SEL"
                    envt.decrement()
                    print()
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
//        }
        .onAppear{
            //            globalState.complete(.dasi)
        }
    }
}

struct DASICompleteView_Previews: PreviewProvider {
    static var previews: some View {
        DASICompleteView()
            .environmentObject(DASIContentState())
    }
}
