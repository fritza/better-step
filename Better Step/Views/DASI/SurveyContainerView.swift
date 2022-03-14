//
//  SurveyContainerView.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/7/22.
//

import SwiftUI

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
                    contentEnvt.selected?.goForward()
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
