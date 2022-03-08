//
//  DASIOnboardView.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/7/22.
//

import SwiftUI

struct DASIOnboardView: View {
static let instructions = """
In this part of the assessment, you will be asked \(DASIQuestion.count) questions about how well you do with various activities.

Answer “Yes” or “No” to each. You will be able to move backward and forward through the questions, but you must respond to all for this exercise to be complete.
"""

    @EnvironmentObject var envt: DASIContentState


    // TODO: Add the forward/back bar.

    var body: some View {
        NavigationView {
            VStack {
//                HStack {
//                        Button("\(Image(systemName: "arrow.left")) Previous") {
//                            envt.selected = .questions
//                            envt.pageNum = DASIQuestion.count
//                    }
//                    Spacer()
//                }.frame(height: 80)
//                .background(Color.gray)

                Spacer()
                GenericInstructionView(
                    titleText: "Activity Survey",
                    bodyText: Self.instructions,
                    sfBadgeName: "checkmark.square",
                    proceedTitle: "Continue") {
                        envt.increment()
                    }
                    .padding()
            }
//            .navigationTitle("DASI Survey")
            .navigationBarHidden(true)
        }
        .onAppear{
        }
    }
}

struct DASIOnboardView_Previews: PreviewProvider {
    static var previews: some View {
        DASIOnboardView()
            .environmentObject(DASIContentState(.landing))
    }
}
