//
//  UsabilitySummaryView.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/22/22.
//

import SwiftUI

let bgColors: [UIColor] = [
    
    ]

/// A `View` listing all usability questions and the user's responses.
struct UsabilitySummaryView: View {
    // FIXME: Conform UsabilityContainer to own, not envt, its controller.
    @EnvironmentObject var controller: UsabilityController

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
                UsabilitySummaryView()
                    .environmentObject(
                        UsabilityController(phase: .summary,
                                            questionID: 1))
                    .padding()
            }
    }
}
