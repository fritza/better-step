//
//  SurveyView.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/19/21.
//

import SwiftUI

let surveyNarrative = """
This exercise asks you to respond to questions from a standard assessment of how free you are in your daily life.
"""

final class BoolBearer: ObservableObject, CustomStringConvertible {
    @Published var isSet: Bool

    init(initially: Bool = false) {
        isSet = initially
    }

    var description: String {
        "BoolBearer (\(isSet))"
    }
}

struct SurveyView: View {
    @StateObject private var wrappedShowing = BoolBearer(initially: false)

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                GenericInstructionView(
                    bodyText: surveyNarrative, sfBadgeName: "checkmark.square")
                    .navigationTitle("DASI Survey")
                    .padding(32)

                NavigationLink(
                    destination: {
                        () -> AnyView in
                        print("Destination DASI:", wrappedShowing)
                        return AnyView(DASIQuestionView(
                            question: DASIQuestion.with(id: 1))
                        .environmentObject(wrappedShowing)
                                       )
                        }()
                    ,
                    isActive: {
                        print("NavLink value =", wrappedShowing)
                        let retval = $wrappedShowing.isSet
                        return retval
                        }(),
                    label: { EmptyView() }
                )

                Button("Proceed (root)", action: {
                    wrappedShowing.isSet = true
                    print("ROOT PROCEED TAPPED",
                          "setting value is now", wrappedShowing.isSet)
                })
                Spacer()
            }
            .onDisappear {
                print("root view is disappearing:", wrappedShowing.isSet)
            }
        }
    }
}

struct SurveyView_Previews: PreviewProvider {
    static var previews: some View {
        SurveyView()
    }
}
