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

//let nextSteps = "NON-GLOBAL nextSteps"

// FIXME: Should there be a Back button?

struct DASICompleteView: View, ReportingPhase {
    typealias SuccessValue = DASIResponseList

    @AppStorage(AppStorageKeys.collectedDASI.rawValue) var collectedDASI: Bool = false

    let completion: ClosureType
    init(_ completion: @escaping ClosureType) {
        self.completion = completion
    }

    @EnvironmentObject private var responses: DASIResponseList
    @EnvironmentObject private var questions: DASIPageSelection
//    @EnvironmentObject private var phaseManager: PhaseManager

    var allItemsAnswered: Bool {
        return responses.unknownResponseIDs.isEmpty
    }

    var nextSteps: String {
        if
        allItemsAnswered
//            phaseManager.allTasksFinished
        {
            return "\nPlease proceed to the “Report” view to submit your information to the team."
        }
        else {
            return "\nNow select the “Walk” tab below to proceed to the walking portion of the exercise."
        }
    }

    var instructions: String {
        var retval = completionText + nextSteps
        if !allItemsAnswered {
            let empties = responses.unknownResponseIDs
            retval += startIncompleteText + " " + "\(empties.count)" + endIncompleteText
        }
        return retval
    }

    var body: some View {
        VStack {
            GenericInstructionView(
                titleText: "x",
                bodyText: instructions, // + completionText,
                sfBadgeName: "checkmark.square")
            .padding()
        }
        .navigationTitle("Survey Complete")
        .toolbar {
// TODO: Replace with ToolbarItem
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button("← Back") {
                    questions.decrement()
                }
                gearBarItem()
            }
        }
        .onAppear{
            // IF ALL ARE ANSWERED
            if allItemsAnswered {
                collectedDASI = true
                completion(.success(responses))
#warning("Find some way to preserve DASI-finished")
//
//                AppStage.shared
//                    .completionSet
//                    .insert(.dasi)
                // FIXME: Also, why is this in onAppear?
                // TODO: Maybe create the report data on completionSet changing.
            }
            else {
                completion(.failure(AppPhaseErrors.shortageOfDASIResponsesBy(responses.unknownResponseIDs.count)))
            }
        }
    }
}

struct DASICompleteView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DASICompleteView() {
                _ in
            }
            // FIXME: These will need better initializer
                .environmentObject(DASIPageSelection(.completion))
                .environmentObject(DASIResponseList())
//            .environmentObject(PhaseManager())
        }
    }
}
