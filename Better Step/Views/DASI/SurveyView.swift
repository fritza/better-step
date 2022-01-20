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
    @Published var showGreeting  : Bool
    @Published var showQuestions : Bool
    @Published var showCompletion: Bool
    func ask()      { (showQuestions, showGreeting, showCompletion) = (true, false, false) }
    func greet()    { (showGreeting, showQuestions, showCompletion) = (true, false, false) }
    func complete() { (showCompletion, showGreeting, showQuestions) = (true, false, false) }

//    @Published var isSet: Bool

    init(initially: Bool = false) {
//        isSet = initially

        (showGreeting, showQuestions, showCompletion) = (true, false, false)
    }

    var description: String {
        var status = "Completed"
        if showGreeting { status = "Greeting" }
        else if showQuestions { status = "Questions" }
        return "BoolBearer (\(status))"
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
                        return AnyView(DASIQuestionView(
                            question: DASIQuestion.with(id: 1))
                        .environmentObject(wrappedShowing)
                                       )
                        }()
                    ,
                    isActive: {
                        let retval = $wrappedShowing.showQuestions
                        return retval
                        }(),
                    label: { EmptyView() }
                )

                Button("Proceed (root)", action: {
//                    wrappedShowing.isSet = true
                    wrappedShowing.ask()
                })
                Spacer()
            }
            .onDisappear {
                print("root view is disappearing:", wrappedShowing
                )
            }
        }
    }
}

struct SurveyView_Previews: PreviewProvider {
    static var previews: some View {
        SurveyView()
    }
}
