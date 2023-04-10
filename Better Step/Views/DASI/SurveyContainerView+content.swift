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
                // TODO: Audit for correct response list
            case .success(let responseList):
                let completedCSV = responses.csvLine
                print(#function, #fileID, #line, "completed CSV =", completedCSV)
                tempCSV = completedCSV
                completion(.success(responseList))

            case .failure(let error):
                let nsError = error as NSError
                if nsError.domain == DASICompleteView.pageBackErrorDomain {
                    dasiPhaseState = .question
                }
                else {
                    fatalError("Shouldn’t get an error from DASICompleteView.")
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Questions
    @ViewBuilder
    func questionPageView() -> some View {
        DASIQuestionView() {
            result in
            if let pair = try? result.get() {
                print(#function, #fileID, #line, "completed CSV =", responses)
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
