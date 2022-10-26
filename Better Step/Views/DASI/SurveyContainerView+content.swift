//
//  SurveyContainerView+content.swift
//  Better Step
//
//  Created by Fritz Anderson on 10/23/22.
//

import Foundation
import SwiftUI

extension SurveyContainerView {
    // MARK: - Landing
    @ViewBuilder
    func landingPageView() -> some View {
        DASIOnboardView() { result in
            switch result {

            case .failure(_):
                fatalError("\(#function) - error Can't Happen.")
            case .success(_):
                dasiPhaseState = .question
            }
        }
        .navigationBarBackButtonHidden(true)
    }


    // MARK: - Completion
    @ViewBuilder
    func completionPageView() -> some View {
        DASICompleteView(responses: responses) {
            result in
            switch result {
            case .success(_):
                let completedCSV = responses.csvLine
                csvStash = completedCSV!
                // TODO: See if the unwrap is okay.

            case .failure(_):
                fatalError("Shouldn’t get an error from DASICompleteView.")
            }
        }
        .navigationBarBackButtonHidden(true)
    }

/*
 var nextSteps: String {
     if allItemsAnswered {
         return "\nTap “Continue” to complete your report."
     }
     else {
         return "\nUse the “← Back” button to review your answers."
     }
 }
 The calling
 */


    // MARK: - Questions
    @ViewBuilder
    func questionPageView() -> some View {
        DASIQuestionView(answerList: responses) {
            result in
            if let pair = try? result.get() {
                switch pair.0 {
                case .landing:
                    dasiPhaseState = .landing
                case .completed:
                    dasiPhaseState = .completed
                default: fatalError()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
