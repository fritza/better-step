//
//  SurveyRootView.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/3/22.
//

import SwiftUI
import Foundation


final class DASIPresentation: ObservableObject, CustomStringConvertible {
    // Combine (or NavigationLink) insists on
    // binding to _optional_ stage. So I add the
    // optional and alter .description to handle
    // the nil value.
    @Published var stage: DASIStages?

    init(stage: DASIStages? = nil) {
        self.stage = stage
    }
    var description: String {
        stage?.description ?? "nil stage"
    }
}

struct ToyView: View {
    let label: String
    let dest: DASIStages
    @EnvironmentObject var envo: DASIPresentation

    init(label: String,
         destination: DASIStages) {
        self.dest = destination
        self.label = label }

    var body: some View {
        VStack {
            Text("The \(label) view")
            Button("Switch over") {
                envo.stage?.goForward()
            }
        }
        .navigationBarBackButtonHidden(true)

    }
}

struct SurveyRootView: View {
    @StateObject var dasiState: DASIPresentation = DASIPresentation(stage: .greeting)

    var body: some View {
        NavigationView {
            VStack {
                Text("\(dasiState.description)")
                Button("to other non-present") {
//                    dasiState.stage = dasiState.stage?.goForward()
                }

                NavigationLink(tag: DASIStages.greeting,
                               selection: $dasiState.stage) {
                    
                    ToyView(label: "from greeting", destination: .completion)
                        .environmentObject(dasiState)
                } label: { EmptyView() }


                NavigationLink(tag: DASIStages.completion,
                               selection: $dasiState.stage) {
                    ToyView(label: "from completion", destination: .greeting)
                        .environmentObject(dasiState)
                } label: { EmptyView() }

                ForEach(
                    QuestionID.min.rawValue..<QuestionID.max.rawValue+1) {
                        qidRawValue in
                        Text(
                            "presenting \(qidRawValue.qid.description)"
                        )

                        NavigationLink(
                            tag: DASIStages.presenting(
                                question: qidRawValue.qid),
                            selection: $dasiState.stage)
                        {
                            Text("In the ForEach")
                            Text("\(dasiState.stage?.advance().description ?? "nothing")")
                        }
                    label: { Text("Not a button") }

                        // WAS THE FOLLOWING IN A LABEL OR WHAT?
//                        ToyView(label: "from completion",
//                                destination: .greeting)
//                            .environmentObject(dasiState)
                    }


                NavigationLink(tag: DASIStages.completion,
                               selection: $dasiState.stage) {
                    ToyView(label: "from completion", destination: .greeting)
                        .environmentObject(dasiState)
                } label: { EmptyView() }
            }
            .navigationTitle("DASI Survey")
        }
        .onAppear {
            dasiState.stage = .greeting
        }
        //        .navigationBarBackButtonHidden(true)

    }
}

struct SurveyRootView_Previews: PreviewProvider {
    static var previews: some View {
        SurveyRootView(
//            initialState: .presenting(question: QuestionID(3))
        )
    }
}
