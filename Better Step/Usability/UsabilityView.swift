//
//  UsabilityView.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/11/22.
//

import SwiftUI

let addedLabels = [
    " (Not at all)",   // 1
    "", "",
    " (Acceptable)",     // 4
    "", "",
    " (Excelllent)"    // 7
]

struct QLimits {
    static let startIndex = 0
    static let endIndex   = UsabilityQuestion.endIndex // UsabilityQuestion.questions.count
    static let indexRange = (startIndex ..< endIndex)
}

/// The core of the usability-survey stack. Present the text of a question and collect the user's response via 7 buttons on a scale.
///
/// Clients provide a questin ID and a binding to the response. Responses are also published via the closure the client provides.
struct UsabilityView: View, ReportingPhase {
    typealias SuccessValue = (question: Int, response: Int?)
    var completion: ClosureType


    //    @Binding private var resultingChoice: Int
    // FIXME: Conform UsabilityContainer to own, not envt, its controller.
    //    @EnvironmentObject private var controller: UsabilityPageSelection

    private let arbitraryCheckmarkEdge: CGFloat =  32
    private let arbitraryButtonWidth  : CGFloat = 240

    /// The ID (not index) of the question currently displayed.
    @State private var questionID       : Int
    /// The response value (1–7) for the question currently displayed.
    @State private var currentSelection : Int?

    init(questionID: Int, selectedAnswer: Int? = nil,
         completion: @escaping ClosureType) {
        ( self.currentSelection, self.questionID, self.completion ) =
        (selectedAnswer, questionID,  completion)
    }

    /// A `@ViewBuilder` for a title `View`
    ///
    /// I have no idea what this is doing here.
    //    static func TViewBuilder<T: View>(
    //        @ViewBuilder builder: () -> T
    //    ) -> some View {
    //        builder()
    //    }

    @ViewBuilder
    func buttonTitleView(index: Int, width: CGFloat) -> some View {
        HStack(alignment: .center, spacing: 16) {
            if let currentSelection,
               index == currentSelection {
                // If the button index corresponds to
                // the choice, display a circled checkmark.
                Image(systemName: "checkmark.circle")
                    .symbolRenderingMode(.hierarchical)
            }
            else {
                // Not selected: fill the checkmark's place with something the same size.
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width : arbitraryCheckmarkEdge,
                           height: arbitraryCheckmarkEdge)
            }
            Text("\(index)")
            Text(addedLabels[index-1])
                .font(.body)
        }
        .alignmentGuide(HorizontalAlignment.center, computeValue: { dims in
            width/2.0
        })

        .frame(width: width)
    }

    /// Stack of 7 buttons for the user's selection.
    @ViewBuilder
    func ratingsStack() -> some View {
        VStack(alignment: .leading) {
            ForEach(1..<8) { index in
                Button {
                    currentSelection = index
                    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { timer in
                        completion(.success(completionValue))
                    }
                }
            label: {
                buttonTitleView(index: index, width: arbitraryButtonWidth)
            }       // button label
            }       // ForEach
            .buttonStyle(.bordered)
            .font(.title)
        }
    }

    var canIncrement: Bool { questionID < (QLimits.endIndex - 1 )}
    var canDecrement: Bool { questionID >  QLimits.startIndex    }
    var completionValue: SuccessValue {
        (question: questionID, response: currentSelection)
    }

    // MARK: - body
    var body: some View {
        ratingsStack()
            .animation(.easeInOut, value: questionID)
            .onDisappear() {
                completion(.success(
                    completionValue
                ))
            }
            .toolbar {
                // TODO: Replace with ToolbarItem
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("← Back") {
                        // No need to range-check, the .disabled does that.
                        completion( .success(completionValue) )
                        questionID -= 1
                    }
                    .disabled(!canDecrement)
                }

                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    gearBarItem()
                    Button("Next →") {
                        completion( .success(completionValue) )
                        questionID += 1
                    }
                    .disabled(canIncrement)
                }
            }
            .navigationTitle("Usability")
            .navigationBarBackButtonHidden(true)
    }
}

    struct UsabilityView_Previews: PreviewProvider {
        static let question = UsabilityQuestion(id: 3, text: "Was this easy to use?")
        static let longQuestion = UsabilityQuestion(id: 4, text: "Compared to the hopes and dreams of your life, has this walking exercise been a help?")
        
        @State static var selectedAnswer = 3
        static var otherSelectedAnswer = 0

        static var previews: some View {
            NavigationView {

                UsabilityView(questionID: 0) { resultValue in
                    guard let pair = try? resultValue.get() else {
                        print("UsabilityView should not fail.")
                        fatalError()
                    }

                    print("value for", pair.0, "is", pair.1 ?? "not selected")
                }

            }
//            .environmentObject(UsabilityPageSelection())
            //            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
        }
    }
