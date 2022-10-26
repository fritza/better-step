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
    typealias SuccessValue = ()


    @AppStorage(AppStorageKeys.collectedDASI.rawValue) var collectedDASI: Bool = false

    let completion: ClosureType
    let dasiResponses: DASIResponseList
    init(responses: DASIResponseList,
         _ completion: @escaping ClosureType
         ) {
        self.completion = completion
        self.dasiResponses = responses
    }

    var nextSteps: String {
        if dasiResponses.isReadyToPublish {
            return "\nTap “Continue” to complete your report."
        }
        else {
            return "\nUse the “← Back” button to review your answers."
        }
    }

    var instructions: String {
        var retval = completionText + nextSteps
        if !dasiResponses.isReadyToPublish {
            let empties = dasiResponses.unknownResponseIDs
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
                proceedEnabled: dasiResponses.isReadyToPublish
            ) {
                // Upon tap of the proceed button
                completion(.success(()))
            }
            .padding()
        }
        .navigationTitle("Survey Complete")
        .toolbar {
            // TODO: Replace with ToolbarItem
            ToolbarItem(placement: .navigationBarLeading) {
                Button("← Back") {
                    completion(.success(()))
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                gearBarItem()
// FIXME: Use the view modifier
            }
        }
    }
}

struct DASICompleteView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DASICompleteView(responses: DASIResponseList()) {
                _ in
            }
        }
    }
}
