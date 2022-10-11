//
//  SurveyContainerView.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/7/22.
//

import SwiftUI

struct SurveyContainerView: View, ReportingPhase {
    let completion: ((Result<DASIResponseList, Error>) -> Void)!

    #warning("Be sure to initialize Pages and Response list")
    @StateObject var contentEnvt = DASIPageSelection()
    @StateObject var responses   = DASIResponseList()

    // FIXME: YUCK! if this doesn't easily work…
    // Oh gosh — what would I have to do to make it a navigable view like the top level?
    // Given that there are no optional branches, maybe there is simply no need.

    var body: some View {
        NavigationView {
            VStack {
                Text(
                    "SHOULD NOT APPEAR(\(contentEnvt.selected?.description ?? "EMPTY"))"
                )
//                Button("RATS Next") {
//                    assert(contentEnvt.selected != nil)
////                    contentEnvt.selected =
//                    contentEnvt.selected?.goForward()
//                }
                NavigationLink(
                    isActive: $contentEnvt.refersToQuestion,
                    destination: {
                        DASIQuestionView(answerState: .unknown)
                            .navigationBarBackButtonHidden(true)
                    },

                    label: { EmptyView() }
                )
                .hidden()

                NavigationLink(
                    tag: DASIStages.landing,
                    selection: $contentEnvt.selected,
                    destination: {
                        DASIOnboardView()
                        .navigationBarBackButtonHidden(true)
                },
                    label: {EmptyView()}
                )
                .hidden()

                NavigationLink(isActive: $contentEnvt.isCompleted,
                               destination: {
                    DASICompleteView() {
                        result in
                        switch result {
                        case let .success(answers):
                            print("Got", answers.answers.count)
                            completion(.success(answers))
                            break

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
                    }
                        .navigationBarBackButtonHidden(true)
                },
                               label: {EmptyView()}
                )
                .hidden()
            }
            // FIXME: This doesn't update global completion.
            .onDisappear {
#warning("As a ReportingPhase, hit the callback for complete/incomplete")


                // Does this belong at disappearance
                // of the tab? We want a full count of
                // responses + concluding screen.
                // ABOVE ALL, don't post the initial screen
                // as soon as the conclusion screen is
                // called for.
//                if !responses.unknownResponseIDs.isEmpty {
//                    BSTAppStages.dasi.didComplete()
//                }
            }
        }
        .environmentObject(contentEnvt)
        .environmentObject(responses)
    }
}

struct SurveyContainerView_Previews: PreviewProvider {
    static var previews: some View {
        SurveyContainerView(completion: {
            result in
            print("Result:", result)
        })
//            .environmentObject(DASIPageSelection())
            .environmentObject(DASIResponseList())
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
