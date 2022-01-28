//
//  DASICompleteView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/28/22.
//

import SwiftUI

fileprivate let completionText = """
BUG: There should be a Back button.

You have completed the survey portion of this exercise.

When you're ready, select the tab (below) marked "Walk" to proceed to the walking portion.

- or -

If you've already completed your walk, proceed to the "Report" view to submit your information to the team.
"""
// FIXME: - Make the instructions dynamic
//          depending on whether all parts have completed.
// FIXME: Should there be a Back button?

struct DASICompleteView: View {
    var body: some View {
        NavigationView {
            GenericInstructionView(
                titleText: "Survey Complete",
                bodyText: completionText,
                sfBadgeName: "checkmark.square")
        }
    }
}

struct DASICompleteView_Previews: PreviewProvider {
    static var previews: some View {
        DASICompleteView()
    }
}
