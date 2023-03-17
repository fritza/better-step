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
    @State var shouldShowActivity = false
    
    init(_ closure: @escaping ClosureType) {
        completion = closure
    }

    @State var showResetAlert = false

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
                shouldShowActivity = true
                ASKeys.lastCompletionValue = Date()
            }
            Spacer()
        }.font(.title3)
            .reversionAlert(on: $showResetAlert)
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

    let fallbackPhase: TopPhases
//    @State var showRewindAlert = false
    @State var shouldAlertDisclaimer = false

    // TODO: Is this the place to name the next step?

    @State var showAlert = false

    typealias SuccessValue = Void
    let completion: ClosureType
    // Warning: Completion closure is never called.")

    let error: Error?
    init(failing: TopPhases, error: Error? = nil, closure: @escaping ClosureType) {
        self.fallbackPhase = failing
        completion = closure
        self.error = error
    }

    var formattedBodyText: String {
        var insertion = ""
        if let phaseName = Self.phasesAndNames.first(where: {
            pair in
            pair.key == fallbackPhase
        })?.value {
            insertion = "(\(phaseName)) "
        }

        if let error {
            return """
The app could not recover from an error in the stage \(insertion)that couldn't collect its data:

\(error.localizedDescription)
"""
        }
        else {
            return """
Because this session was cancelled, the app must go back to a stage (\(insertion)) for you to try again.

If you want to retry from the start, tap the ⚙️ button.
"""
        }
    }

    var explanation: String {
        var insertion = ""
        if let phaseName = Self.phasesAndNames.first(where: {
            pair in
            pair.key == fallbackPhase
        })?.value {
            insertion = "(\(phaseName)) "
        }
        return """
Because this session was cancelled, the app must go back to the stage \(insertion)that couldn't collect its data. Tap “Revert” to rewind to that point.
"""
    }
    // arrow.turn.left.down

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                GenericInstructionView(
                    sfBadgeName: "arrow.turn.left.down",
                    lowerText: self.explanation,
                    proceedTitle: "Revert") {
                        shouldAlertDisclaimer = true
                    }
            }
            .reversionAlert(on: $showAlert)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    ReversionButton(toBeSet: $showAlert)
//                }
//            }
            .navigationBarTitle("Recovery")
        }
        .alert("Not complete", isPresented: $shouldAlertDisclaimer, actions: {},
               message: {Text ("Revert-from-error isn't finished. Tap the gear button to wind back to the start\n\nBe sure to tell Fritz Anderson (fritza@uchicago.edu) exactly what led you here.")})
        .reversionAlert(on: $showAlert)
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
