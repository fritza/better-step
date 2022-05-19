//
//  ButtonSurveyView.swift
//  Better Step
//
//  Created by Fritz Anderson on 5/19/22.
//

import SwiftUI

// MARK: - ButtonSurveyView
struct ButtonSurveyView: View {
    @EnvironmentObject var allResponses: SurveyResponses
    @State var score: Double
    let index: Int

    init(id: Int, score: Double) {
        self.index = id
        self.score = score
    }

    func buttonLabel(_ rank: Int) -> some View {
        return Label("\(rank)",
                     systemImage:
                        (rank == Int(score)) ? "checkmark.circle" : "")
    }

    var body: some View {
        VStack {
            SurveyPromptView(
                index: index,
                prompt: USurveyQuestion.all[index-1].text)
            List((1..<8)) {
                i in
                Button {
                    score = Double(i)
                } label: {
                    buttonLabel(i)
                }

            }
        }.navigationTitle("Survey")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("← Back") {   }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Next →") {   }
                }
            }
    }
}

struct ButtonSurveyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            VStack {
                Spacer()
                ButtonSurveyView(id: 3, score: 3)
                    .environmentObject(SurveyResponses())
                Spacer()
            }
        }
    }
}
