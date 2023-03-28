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
                // TODO: See if the unwrap is okay.
                completion(.success(responseList))

            case .failure(let error):
                let nsError = error as NSError
                if nsError.domain == DASICompleteView.pageBackErrorDomain {
                    let page = nsError.code


                    // TODO: Switch to questions and the page.
                    dasiPhaseState = .question
                    // okay, now set the page?
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
        // When there is a missing-answer ID,
        // We want to set pageNumber for the view.
        // NB the .DASIQuestionView.pageNumber is supposed to be
        // private. Maybe add an optional parameter for
        // DASIQuestionView to initialize with a page number.
        DASIQuestionView() {
            result in
            if let pair = try? result.get() {
                print(#function, #fileID, #line, "completed CSV =", responses)
                switch pair.0 {
                case .landing:
                    dasiPhaseState = .landing
                case .completed:

//                    "Completion" may not be complete,
//                    in that some answers may be missing.
//                    This has to be intercepted somewhere.
//                    At present, this is at DASICompleteView,
                    // upon entry.

                    print(#function, #fileID, #line, "completed signalled")

                    dasiPhaseState = .completed
                default: fatalError()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
