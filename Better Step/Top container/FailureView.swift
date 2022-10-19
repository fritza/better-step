//
//  FailureView.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/21/22.
//

import SwiftUI

struct ConclusionView: View, ReportingPhase {
    typealias SuccessValue = Void
    let completion: ClosureType
    init(_ closure: @escaping ClosureType) {
        completion = closure
    }

    var body: some View {
        VStack {
            Text("Congratulations, you're done.")
            Button("Complete") {
                completion(.failure(AppPhaseErrors.NOS))
                // Why do I have to instantiate Void?
            }
        }
    }
}


/// Display a next-steps page with a "Revert" button that directs the user to the entry to DASI, or Usability, or Walk, depending on what failed.
///
/// Instantiated for the TopPhases.failed tag.
struct FailureView: View, ReportingPhase {
    static let phasesAndNames: KeyValuePairs<TopPhases, String> = [
        .walking    : "timed walk",
        .usability  : "usability survey",
        .dasi       : "activity survey"
]

    let fallbackPhase: TopPhases
    @State var showRewindAlert = false
    @State var shouldAlertDisclaimer = false

    // TODO: Is this the place to name the next step?

    typealias SuccessValue = Void
    let completion: ClosureType
    init(failing: TopPhases, closure: @escaping ClosureType) {
        self.fallbackPhase = failing
        completion = closure
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
                    bodyText: self.explanation,
                    sfBadgeName: "arrow.turn.left.down",
                    proceedTitle: "Revert") {
                        shouldAlertDisclaimer = true
                    }
            }
            .reversionToolbar($showRewindAlert)
            .navigationBarTitle("Recovery")
        }
        .alert("Not complete", isPresented: $shouldAlertDisclaimer, actions: {},
               message: {Text ("Revert-from-error isn't finished. Tap the gear button to wind back to the start\n\nBe sure to tell Fritz Anderson (fritza@uchicago.edu) exactly what led you here.")})
        .padding()
    }
}


/*
struct FailureView: View, ReportingPhase {
    typealias SuccessValue = Void
    let completion: ClosureType
    let failedPhase: TopPhases
    init(failing: TopPhases, _ closure: @escaping ClosureType) {
        failedPhase = failing
        completion = closure
    }

    var body: some View {
        VStack {
            Text("""
If you’re seeing this, the last thing you did resulted in a programming error. Let fritza@uchicago.edu know.
""")
        }
        .navigationBarTitle("App Failed")
    }
}
 */

struct FailureView_Previews: PreviewProvider {
    static var previews: some View {
            FailureView(failing: .walking) {
                _ in
            }
    }
}
