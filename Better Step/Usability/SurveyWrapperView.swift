//
//  SurveyWrapperView.swift
//  Better Step
//
//  Created by Fritz Anderson on 5/23/22.
//

import SwiftUI

struct SurveyWrapperView: View {
    // TODO: Will this be yet another layer down in the NavigationView hierarchy?
    @EnvironmentObject var responseRecord: SurveyResponses
    @State private var selectionPage = 1

    @State var currentResponse: Int? = nil

    private func incrementPage() {
        responseRecord.respond(to: selectionPage, with: currentResponse)

        selectionPage = (selectionPage >= ButtonSurveyView.count) ?
        selectionPage :
        selectionPage+1

        currentResponse = responseRecord.response(for: selectionPage)
    }

    private func decrementPage() {
        responseRecord.respond(to: selectionPage, with: currentResponse)

        selectionPage = (selectionPage <= 1) ?
        selectionPage :
        selectionPage-1

        currentResponse = responseRecord.response(for: selectionPage)
    }

    var body: some View {
        NavigationView {
            VStack {
                ButtonSurveyView(id: selectionPage, score: $currentResponse)
                    .navigationTitle("Usability")
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button("← Back") {
                                decrementPage()
                            }
                            .disabled(selectionPage <= 1)
                            gearBarItem()
                        }
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            Button("Next →") {
                                incrementPage()
                            }
                            .disabled(selectionPage >= ButtonSurveyView.count)
                        }
                    }
                // TODO: Also make it a condition
                //       that all questions be answered.
                if selectionPage == ButtonSurveyView.count {
                    if responseRecord.allAnswered {
                        Button("Continue") {}
                            .padding()
                    }
                    else {
                        Text("You still have some questions to answer.")
                            .font(.caption)
                            .padding()
                    }
                }
            }
        }
    }
}

struct SurveyWrapperView_Previews: PreviewProvider {
    static var previews: some View {
        SurveyWrapperView()
            .environmentObject(SurveyResponses())
    }
}
