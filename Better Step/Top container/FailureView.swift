//
//  FailureView.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/21/22.
//

import SwiftUI
import ActivityKit

// MARK: - Conclusion View
/// A view that annpunces the successful completion of the workflow.
///
/// Its ``SuccessValue`` as a ``ReportingPhase`` is `Void`.
struct ConclusionView: View, ReportingPhase {
    typealias SuccessValue = Void
    let completion: ClosureType
    
    init(_ closure: @escaping ClosureType) {
        completion = closure
    }

//    @State var showResetAlert = false

    var body: some View {
        VStack {
            Spacer()
            Text("Congratulations, you're done.")
            Spacer()
            Text("Tap ") +
            Text("Submit").fontWeight(.semibold).foregroundColor(.blue) +
            Text(" to send a report.\n(bug: the cose as-is sends the file when the last task is complete. (It's gone already.\nThe Submit button still presents the Activty (mail, etc.) sheet to double-check.")
            Spacer()
            Button("Submit") {
                ASKeys.lastCompletionValue = Date()
            }
            Spacer()
        }.font(.title3)
            .navigationTitle("Completed")
    }
}

// MARK: - Failure View

/// Display a next-steps page with a "Revert" button that directs the user to the entry to DASI, or Usability, or Walk, depending on what failed.
///
/// Instantiated for the TopPhases.failed tag.
///
/// Its ``SuccessValue`` as a ``ReportingPhase`` is `Void`.
/// - bug: The completion closure **is never called.**
struct FailureView: View, ReportingPhase {
    static let phasesAndNames: KeyValuePairs<TopPhases, String> = [
        .walking    : "timed walk",
        .usability  : "usability survey",
        .dasi       : "activity survey"
]

    typealias SuccessValue = Void
    let completion: ClosureType
    // Warning: Completion closure is never called.")

    let error: Error?
    init(failing: TopPhases, error: Error? = nil, closure: @escaping ClosureType) {
        completion = closure
        self.error = error
    }

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                GenericInstructionView(
                    sfBadgeName: "arrow.turn.left.down",
                    lowerText: "This view, which is to handle completion of session due to irremediable error, will be replaced soon.",
                    proceedTitle: "OK") {
                        completion(.failure(
                            self.error ??
                            NSError(domain: "FailureViewDomain", code: 0)))
                    }
            }
            .navigationBarTitle("Recovery")
        }
        .padding()
    }
}

// MARK: - Previews
struct FailureView_Previews: PreviewProvider {
    static var previews: some View {
            FailureView(failing: .walking) {
                _ in
            }
    }
}

struct ConclusionView_Previews: PreviewProvider {
    static var previews: some View {

        NavigationView {
            ConclusionView {
                _ in
            }
        }
    }
}
