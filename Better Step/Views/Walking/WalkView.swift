//
//  WalkView.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/19/21.
//

import SwiftUI

let walkingNarrative = """
This exercise will assess your stride and pace though a short (six-minute) walk. An alarm sound to signal the beginning and the end of the exercise.

Tap “Proceed" when you are ready
"""

final class WalkingSequence: ObservableObject, CustomStringConvertible {
    var description: String {
        "WalkingSequence(progress: \(showProgress), countdown: \(showCountdown))"}

    @Published var showProgress: Bool
    @Published var showCountdown: Bool

    init() {
        showProgress = false; showCountdown = false
    }
}


struct WalkView: View {
    @StateObject private var sequencer = WalkingSequence()

    var body: some View {
        // FIXME: The figure does not conform to the image aspect ratio.
        NavigationView {
            GenericInstructionView(
                titleText: "Walking Test",
                bodyText: walkingNarrative, sfBadgeName: "figure.walk",
                proceedTitle: "Proceed") {

                }
                .padding(32)
            NavigationLink(
                destination: {
                    AnyView(WalkProgressView())
                        .environmentObject(sequencer)
                }(),
                isActive: $sequencer.showCountdown,
                label: { EmptyView()}
            )
        }
    }
}

struct WalkView_Previews: PreviewProvider {
    static var previews: some View {
        WalkView()
    }
}
