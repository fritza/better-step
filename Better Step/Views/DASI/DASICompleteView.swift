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
    typealias SuccessValue = (DASIState, DASIResponseList)
    @AppStorage(AppStorageKeys.collectedDASI.rawValue) var collectedDASI: Bool = false

    let completion: ClosureType
    init(_ completion: @escaping ClosureType) {
        self.completion = completion
    }

    @EnvironmentObject private var responses: DASIResponseList
//    @EnvironmentObject private var pager    : DASIPageSelection

    var allItemsAnswered: Bool {
        return responses.unknownResponseIDs.isEmpty
    }

    var nextSteps: String {
        if allItemsAnswered {
            return "\nTap “Continue” to complete your report."
        }
        else {
            return "\nUse the “← Back” button to review your answers."
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
                titleText: nil,
                bodyText: instructions, // + completionText,
                sfBadgeName: "checkmark.square",
                proceedTitle: "Continue",
                proceedEnabled: allItemsAnswered
            ) {
                // Upon tap of the proceed button
                completion(.success((.completed, responses)))
            }
            .padding()
        }
        .navigationTitle("Survey Complete")
        .toolbar {
            // TODO: Replace with ToolbarItem
            ToolbarItem(placement: .navigationBarLeading) {
                Button("← Back") {
                    completion(
                        .success((.question, responses))
                    )
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                gearBarItem()
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
//            .environmentObject(DASIPageSelection(.completion))
            .environmentObject(DASIResponseList())
            //            .environmentObject(PhaseManager())
        }
    }
}
