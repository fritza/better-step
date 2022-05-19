//
//  ButtonSurveyView.swift
//  Better Step
//
//  Created by Fritz Anderson on 5/19/22.
//

import SwiftUI

// MARK: - ButtonSurveyView
struct ButtonSurveyView: View {
    @EnvironmentObject private var allResponses: SurveyResponses
    @State private var score: Double
    @State private var index: Int

    init(id: Int, score: Double) {
        self.index = id
        self.score = score
    }

    private func buttonLabel(_ rank: Int) -> some View {
        return Label("\(rank)",
                     systemImage:
                        (rank == Int(score)) ? "checkmark.circle" : "")
    }

    var body: some View {
        VStack {
            SurveyPromptView(
                index: index,
                prompt: USurveyQuestion.all[index-1].text)
            .padding()
            List((1..<8)) {
                i in
                Button {
                    score = Double(i)
                } label: {
                    buttonLabel(i)
                }
                // FIXME: How do next/back buttons affect the selection if the toolbar isn't part of this view?
                // Answer: stepping should be done in the superview, which has @State for page number and tracking responses upon leaving a page (in the case of the last page, when the Submit button is tapped — is this something I can do with focus? Shift of focus or submission of the Done button?)
            }
        }
    }
}

struct ButtonSurveyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VStack {
                Spacer()
                ButtonSurveyView(id: 3, score: 3)
                    .environmentObject(SurveyResponses())
                Spacer()
            }
            .navigationTitle("Survey item")

            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("← Back") {   }
                        .disabled(false)
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Next →") {  }
                        .disabled(false)
                }
        }
            }
    }
}
