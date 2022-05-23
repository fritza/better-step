//
//  FullSurveyView.swift
//  Better Step
//
//  Created by Fritz Anderson on 5/19/22.
//

import SwiftUI

struct FullSurveyView: View {
    var body: some View {
        List(1...USurveyQuestion.count, id: \.self) {
            index in
            USurveyQuestionView(id: index, score: 3.0)
        }
        .navigationTitle("Usability Survey")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Done") {
                    print("WHAT NOW?")
                }
            }
            ToolbarItemGroup(placement: .navigationBarLeading) {
                gearBarItem()
            }
        }
    }
}

struct FullSurveyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FullSurveyView()
        }
    }
}
