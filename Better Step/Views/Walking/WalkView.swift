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


let walkingFinished = """
You’ve completed your walk. If you haven’t responded to the DASI survey, tap the "Survey" tab below.
"""

final class WalkingSequence: ObservableObject, CustomStringConvertible {
    var description: String {
        "WalkingSequence(progress: \(showProgress), countdown: \(showCountdown))"}

    @Published var showProgress: Bool
    @Published var showCountdown: Bool
    @Published var showComplete: Bool

    init() {
        showProgress = false; showCountdown = false; showComplete = false
    }
}


struct WalkView: View {
    @StateObject private var sequencer = WalkingSequence()
    @EnvironmentObject var stages: BSTAppStageState

    var body: some View {
        // FIXME: The figure does not conform to the image aspect ratio.
        NavigationView {
            VStack {
                GenericInstructionView(
                    bodyText: walkingNarrative, sfBadgeName: "figure.walk",
                    proceedTitle: "Proceed") {

                    }
                .padding(32)
            NavigationLink(
                destination: {
                    AnyView(WalkProgressView())
                }(),
                isActive: $sequencer.showCountdown,
                label: { EmptyView()}
            )
                NavigationLink(
                    destination: {
                        GenericInstructionView(
                            bodyText: walkingFinished,
                            sfBadgeName: "figure.walk")
                    }(),
                    isActive: $sequencer.showComplete,
                    label: {EmptyView()}
                )
            }
            .navigationTitle("Walking Test")
        }
        .environmentObject(sequencer)
    }
}

struct WalkView_Previews: PreviewProvider {
    static var stageState: BSTAppStageState {
        let stage = BSTAppStageState()
        stage.didComplete(phase: .walk)
        return stage
    }

    static var previews: some View {
        WalkView()
            .environmentObject(stageState)
    }
}
