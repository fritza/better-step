//
//  SurveyPromptView.swift
//  Better Step
//
//  Created by Fritz Anderson on 5/19/22.
//

import SwiftUI

// MARK: - SurveyPromptView
struct SurveyPromptView: View {
    let index: Int
    let prompt: String
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(index): ").font(Font.title3.weight(.semibold))
            Text(prompt)
                .font(Font.title3.weight(.regular))

        }
    }
}

struct SurveyPromptView_Previews: PreviewProvider {
    static var previews: some View {
        SurveyPromptView(index: 8, prompt: "Whenever I made a mistake using Step Test, I could recover easily and quickly.")
//            .padding()
    }
}
