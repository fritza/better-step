//
//  UsabilitySummaryView.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/22/22.
//

/* ===================================
 IT'S OKAY THAT THIS VIEW IS NOT INSTANTIATED.

 It's a useful debugging stage.
 =================================== */

import SwiftUI
#if INCLUDE_USABILITY_SUMMARY

// FIXME: For UsabilitySummaryView - completion is not called.



let bgColors: [UIColor] = [
    
    ]

/// A `View` listing all usability questions and the user's responses.
///
/// Its `SuccessValue` as a ``ReportingPhase`` is `Void`. **Completion closure is not called.** This one is serious.
/// - note Available only if `INCLUDE_USABILITY_SUMMARY` is set at compule time.
struct UsabilitySummaryView: View, ReportingPhase {
    typealias SuccessValue = Void
    let completion: ClosureType
    init(_ completion: @escaping ClosureType) {
        self.completion = completion
    }

    // FIXME: Conform UsabilityContainer to own, not envt, its controller.
    @EnvironmentObject var controller: UsabilityPageSelection

    func question(index: Int) -> UsabilityQuestion {
        UsabilityQuestion.allQuestions[index]
    }

    func questionDescription(index: Int) -> String {
       "\(question(index: index).description)"
    }

    func responseForQuestion(id: Int) -> Int {
        controller.results[id-1]
    }

    func responseStringForQuestion(id: Int) -> String {
        return "\(responseForQuestion(id: id))"
    }

    /// A digit for the user's response, in a gray box.
    @ViewBuilder func responseViewForQuestion(id: Int,
                                              edge: CGFloat) -> some View {
        ZStack(alignment: .center) {
            Rectangle().foregroundColor( // .gray)
                Color(.displayP3, white: 0.9, opacity: 1.0)
                )
            Text(responseStringForQuestion(id: id))
        }.frame(width: edge, height: edge)
            .minimumScaleFactor(0.5)
    }

    /// A row for a given question: ID, response, and text.
    @ViewBuilder func questionRowView(question: UsabilityQuestion) -> some View {
        HStack(alignment: .top) {
            Text("\(question.id.description)")
                .font(.title2).monospacedDigit()
                .frame(width: 32, alignment: .trailing)

            responseViewForQuestion(id: question.id, edge: 24.0)
            Text("\(question.text)")
        }
        .frame(height: 48)
    }

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(UsabilityQuestion.allQuestions) { question in
                questionRowView(question: question)

            }
        }
    }
}

struct UsabilitySummaryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UsabilitySummaryView {
                _ in
                print("UsabilitySummaryView completed.")
            }
                .environmentObject(
                    UsabilityPageSelection(phase: .summary,
                                           questionIndex: 1))
                .padding()
        }
    }
}
#endif
