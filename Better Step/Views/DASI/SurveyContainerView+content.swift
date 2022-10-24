//
//  SurveyContainerView+content.swift
//  Better Step
//
//  Created by Fritz Anderson on 10/23/22.
//

import Foundation
import SwiftUI

extension SurveyContainerView {
    @ViewBuilder
    func landingPageView() -> some View {
        NavigationLink(
            tag: DASIState.landing,
            selection: $dasiPhaseState,
            destination: {
                DASIOnboardView() { _ in
                    dasiPhaseState = .question
                }
                .navigationBarBackButtonHidden(true)
            },
            label: {EmptyView()}
        )
        .hidden()
    }

    @ViewBuilder
    func completionPageView() -> some View {
        NavigationLink(
            tag: DASIState.completed,
            selection: $dasiPhaseState,
            destination: {

                // This code passes the responses up to the top-level container.
                // That's high; this SurveyContainerView
                // already knows when to commit the data
                // TODO: Stop the DASI reporting chain here.
                // See also TopPhaseBuilders, casi_view()

                DASICompleteView() {
                    result in
                    if let pair = try? result.get() {
                        switch pair.0 {
                        case .completed:
                            completion(.success(pair.1))
                        case .question:
                            dasiPhaseState = .question
                        default: fatalError()
                        }
                    }

                    /*
                    switch result {
                    case let .success(answers):
                        print("Got", answers.answers.count)
                        completion(.success(answers))

                    case let .failure(error):
                        if case let AppPhaseErrors.shortageOfDASIResponsesBy(shortage) = error {
                            print("Short by", shortage)
                        }
                        else {
                            print("Unknown:", error)
                            print()
                        }
                        completion(.failure(error))
                    }
                    */
                }
                .navigationBarBackButtonHidden(true)
            },
            label: {EmptyView()}
        )
        .hidden()
    }

    @ViewBuilder
    func questionPageView() -> some View {
        NavigationLink(
            tag: DASIState.question,
            selection: $dasiPhaseState,
            destination: {
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
            },
            label: { EmptyView() }
        )
        .hidden()
    }
}
