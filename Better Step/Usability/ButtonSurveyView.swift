//
//  ButtonSurveyView.swift
//  Better Step
//
//  Created by Fritz Anderson on 5/19/22.
//

import SwiftUI

private struct Agreement: Identifiable, Hashable, Comparable {
    let degree: Int
    let notation: String?
    var id: Int { degree }

    init(degree: Int, notation: String? = nil) {
        (self.degree, self.notation) = (degree, notation)
    }

    static func < (lhs: Agreement, rhs: Agreement) -> Bool {
        lhs.degree < rhs.degree
    }
}


// MARK: - ButtonSurveyView
/// Presents a single item in the usability survey, a full screen for the text of the question and the responses.
///
/// - note: Need a wrapper view to take care of the navigation title, paging between questions, and recording the choices.
struct ButtonSurveyView: View {
    private static let agreementLabels: [Agreement] = [
        .init(degree: 1, notation: "Most Agree"     ), .init(degree: 2),
        .init(degree: 3, notation: "Agree"          ), .init(degree: 4),
        .init(degree: 5, notation: "Disagree"       ), .init(degree: 6),
        .init(degree: 7, notation: "Most Disagree"  ),
        ]
    static var count: Int { agreementLabels.count }

//    let allResponses: SurveyResponses
    @Binding var selectedResponse: Int?
//    @State private var selectedResponse: Int?
    let index: Int

    init(id: Int, score: Binding<Int?>) {
        self.index = id
        self._selectedResponse = score
//        let savedScore = SurveyResponses.shared.response(for: id)
    }

    private func labelIcon(forMatch matches: Bool) -> some View {
        if matches { return AnyView(Image(systemName: "checkmark.circle")) }
        return AnyView(Color.clear.frame(width: 22, height: 2))
    }

    private func buttonLabel(_ pair: Agreement) -> some View {
        var label = "\(pair.degree)"
        if let note = pair.notation {
            label += " - \(note)"
        }

        return Label {
            Text(label)
        } icon: {
            labelIcon(forMatch: pair.degree == self.selectedResponse)
        }
    }

    var body: some View {
        VStack {
            SurveyPromptView(
                index: index,
                prompt: USurveyQuestion.all[index-1].text)
            .padding()
            List((1..<8)) {
                i in
                Button {
                    score = Double(i)
                } label: {
                    buttonLabel(i)
                }
            }
        }
    }
}

struct ButtonSurveyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VStack {
                Spacer()
                ButtonSurveyView(id: 3, score: 3)
                    .environmentObject(SurveyResponses())
                Spacer()
            }
            .navigationTitle("Survey item")

            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("← Back") {   }
                        .disabled(false)
                    gearBarItem()
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Next →") {  }
                        .disabled(false)
                }
            }
        }
    }
}
