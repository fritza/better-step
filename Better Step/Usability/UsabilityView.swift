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

/// The core of the usability-survey stack. Present the text of a question and collect the user's response via 7 buttons on a scale.
///
/// Clients provide a questin ID and a binding to the response. Responses are also published via the closure the client provides.
struct UsabilityView: View, ReportingPhase {
    typealias SuccessValue = Int
    var completion: ClosureType


//    @Binding private var resultingChoice: Int
    // FIXME: Conform UsabilityContainer to own, not envt, its controller.
//    @EnvironmentObject private var controller: UsabilityPageSelection

    private let arbitraryCheckmarkEdge: CGFloat =  32
    private let arbitraryButtonWidth  : CGFloat = 240

    private let questionID: Int
    @Binding var currentSelection: Int
    init(
        questionID: Int,
        selectedAnswer: Binding<Int>,
        completion: @escaping ClosureType) {
            _currentSelection = selectedAnswer
            self.questionID = questionID
            self.completion = completion
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
            if index == currentSelection {
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

    // MARK: - body
    var body: some View {
        VStack {
            // Question ID and text
            HStack(alignment: .top, spacing: 16) {

                // FIXME: Not in the navigationTitle?

                Text("\(questionID)")
                    .font(.largeTitle)
                // Watch for the forced unwrap at UsabilityQuestion:subscript
                Text("\(UsabilityQuestion[questionID].text)")
                    .font(.title2)
            }
            .minimumScaleFactor(0.5)
            .padding()
            Divider()

            // Stack of 7 buttons for the user's selection.
            VStack(alignment: .leading) {
                ForEach(1..<8) { index in
                    Button {
                        currentSelection = index
                        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { timer in
                            completion(.success(index))
                        }
                    }   // button action
                label: {
                    buttonTitleView(index: index, width: arbitraryButtonWidth)
                }       // button label
                }       // ForEach
                .buttonStyle(.bordered)
                .font(.title)
            }           // VStack of buttons
//            Spacer()
//            Button("Continue") {
//                controller.increment()
//            }
        }
        .animation(.easeInOut, value: questionID)
        .onDisappear() {
            completion(.success(currentSelection))
//            controller.storeCurrentResponse()
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

                UsabilityView(questionID: 10, selectedAnswer: $selectedAnswer, completion: { resultValue in
                    print("selected value is", resultValue)
                })
                //            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("← Back") { }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Next →") {}
                }
            }
            }
            .environmentObject(UsabilityPageSelection())
//            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
        }
    }
