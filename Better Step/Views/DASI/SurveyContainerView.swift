//
//  SurveyContainerView.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/7/22.
//

import SwiftUI

/// Observable wrapper on a persistent `DASIStages`.
final class DASIContentState: ObservableObject {
    @Published var selected: DASIStages!
    
    init(_ selection: DASIStages = .landing) {
        selected = selection
        refersToQuestion = selection.refersToQuestion
    }

    /// Reflect the selection of the next page.
    ///
    /// At the end of the question pages, this should advance to `.completion`. There is no increment from `.completion`.
    func increment() {
        selected.advance()
        refersToQuestion = selected.refersToQuestion
    }

    /// Reflect the selection of the previous page.
    ///
    /// From the start of the question pages, this should regress to `.landing`. There is no decrement from `.landing`.
    func decrement() {
        selected.retreat()
        refersToQuestion = selected.refersToQuestion
    }

    @Published var refersToQuestion: Bool
    var questionID: QuestionID? { selected.questionID }
}

struct SurveyContainerView: View {
    @EnvironmentObject var contentEnvt: DASIContentState

    var body: some View {
        NavigationView {
            VStack {
                Text(
                    "SHOULD NOT APPEAR(\(contentEnvt.selected?.description ?? "EMPTY"))"
                )
                Button("RATS Next") {
                    assert(contentEnvt.selected != nil)
//                    contentEnvt.selected =
                    contentEnvt.selected?.advance()
                }
                NavigationLink(
                    isActive: $contentEnvt.refersToQuestion,
                    destination: {
                        DASIQuestionView(answerState: .unknown)
                            .navigationBarBackButtonHidden(true)
                    },

                    label: { EmptyView() }
                )
                NavigationLink(tag: DASIStages.landing,
                               selection: $contentEnvt.selected,
                               destination: {
                    DASIOnboardView()
                        .navigationBarBackButtonHidden(true)
                },
                               label: {EmptyView()}
                )
                NavigationLink(tag: DASIStages.completion,
                               selection: $contentEnvt.selected,
                               destination: {
                    DASICompleteView()
                        .navigationBarBackButtonHidden(true)
                },
                               label: {EmptyView()}
                )
            }
        }
    }
}

struct SurveyContainerView_Previews: PreviewProvider {
    static var previews: some View {
        SurveyContainerView()
            .environmentObject(DASIContentState(.landing))
    }
}

/*
 WORKS: Observing the environment to select self's content.
        Next, how to select the next contained view.
 var body: some View {
     NavigationView {
         VStack {
             Text(contentEnvt.selected.rawValue)
             Button("Next") {
                 contentEnvt.selected = contentEnvt.selected.next
             }
         }
         .navigationTitle("Containment")
     }
 }

 */
