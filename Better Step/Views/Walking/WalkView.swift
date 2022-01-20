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


struct WalkView: View {
    var body: some View {
        // FIXME: The figure does not conform to the image aspect ratio.
        GenericInstructionView(titleText: "Walking Test",
                               bodyText: walkingNarrative, sfBadgeName: "figure.walk",
        proceedTitle: "Proceed") {
            
        }
        .padding(32)
    }
}

struct WalkView_Previews: PreviewProvider {
    static var previews: some View {
        WalkView()
    }
}
