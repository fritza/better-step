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
struct UsabilityView: View {
    @Binding private var resultingChoice: Int
    // FIXME: Conform UsabilityContainer to own, not envt, its controller.
    @EnvironmentObject private var controller: UsabilityPageSelection

    private let arbitraryCheckmarkEdge: CGFloat =  32
    private let arbitraryButtonWidth  : CGFloat = 240

    private let questionID: Int
    private let selectionCallback: (Int) -> Void

    init(
        questionID: Int,
        selectedAnswer: Binding<Int>,
        onSelection callback: @escaping (Int) -> Void) {
            _resultingChoice = selectedAnswer
            self.questionID = questionID
            self.selectionCallback = callback
        }

    /// A `@ViewBuilder` for a title `View`
    ///
    /// I have no idea what this is doing here.
    static func TViewBuilder<T: View>(
        @ViewBuilder builder: () -> T
    ) -> some View {
        builder()
    }

    func titleView(index: Int, width: CGFloat) -> some View {
        Self.TViewBuilder {
            HStack(alignment: .center, spacing: 16) {
                if index == resultingChoice {
                    Image(systemName: "checkmark.circle")
                        .symbolRenderingMode(.hierarchical)
                }
                else {
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
    }

    // MARK: - body
    var body: some View {
        VStack {
            // Question ID and text
            HStack(alignment: .top, spacing: 16) {
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
                        resultingChoice = index
                        selectionCallback(index)
                    }   // button action
                label: {
                    titleView(index: index,
                              width: arbitraryButtonWidth)
                }       // button label
                }       // ForEach
                .buttonStyle(.bordered)
                .font(.title)
            }           // VStack of buttons
            Spacer()
            Button("Continue") {
                controller.increment()
            }
        }
        .animation(.easeInOut, value: questionID)
        .onDisappear() {
            controller.storeCurrentResponse()
        }
        .navigationTitle("Usability")
        .navigationBarBackButtonHidden(true)
    }
}

    struct UsabilityView_Previews: PreviewProvider {
        static let question = UsabilityQuestion(id: 3, text: "Was this easy to use?")
        static let longQuestion = UsabilityQuestion(id: 4, text: "Compared to the hopes and dreams of your life, has this walking exercise been a help?")
        @State static var selectedAnswer = 3
        @State static var otherSelectedAnswer = 0

        static var previews: some View {
            NavigationView {
                UsabilityView(
                    questionID: 10,
                    selectedAnswer: $selectedAnswer,
                    onSelection: { id in
                        print("ID is", id, "what now?")
                    }
                )
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
