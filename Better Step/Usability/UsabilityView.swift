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

// TODO: remove the slide-from-leading animation
//       or make it conistent with the DASI animation
//       (Turns out this is a DASI note, make it consistent with earlier behavior.

// TODO: Anchor the button stack from the bottom
//       Instead of having it animate up and down
//       with the height of the question text.
//
// TODO: Keep the content of the stack from animating
//       (special case of previous.


/// The core of the usability-survey stack. Present the text of a question and collect the user's response via 7 buttons on a scale.
///
/// Clients provide a question ID and a binding to the response. Responses are also published via the closure the client provides.
///
/// The ``SuccessValue`` as a ``ReportingPhase`` is `[Int]`.
struct UsabilityView: View, ReportingPhase {
    @AppStorage(ASKeys.tempUsabilityIntsCSV.rawValue)
    var tempCSV: String = ""

    typealias SuccessValue = [Int]
    var completion: ClosureType

    private let arbitraryCheckmarkEdge: CGFloat =  32
    private let arbitraryButtonWidth  : CGFloat = 240

    /// The  index of the question currently displayed.
    @State private var questionIndex       : Int
    /// The response value (1–7) for the question currently displayed.
    @State private var currentSelection : Int

    @State var showResetAlert = false

    @State private var responses = [Int](repeating: 0, count: UsabilityQuestion.count)
    var canIncrement: Bool { questionIndex < (QLimits.endIndex - 1 )}
    var canDecrement: Bool { questionIndex >  QLimits.startIndex    }
    var completionValue: SuccessValue { responses }


    init(questionIndex: Int, selectedAnswer: Int = 0,
         completion: @escaping ClosureType) {
        ( self.currentSelection, self.questionIndex, self.completion ) =
        (selectedAnswer, questionIndex,  completion)
    }

    @ViewBuilder
    func buttonTitleView(index: Int, width: CGFloat) -> some View {
        HStack(alignment: .center, spacing: 16) {
            if index == currentSelection {
                // If the button index corresponds to
                // the choice, display a circled checkmark.
                Image(systemName: "checkmark.circle")
//                    .symbolRenderingMode(.hierarchical)
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

    // TODO: A brief pause when a buttonis tapped
    //       to display the check and give an
    //       impression that something has happened.
    /// Stack of 7 buttons for the user's selection.
    @ViewBuilder
    func ratingsStack() -> some View {
        VStack(alignment: .leading) {
            ForEach(1..<8) { visibleIndex in
                Button {
                    responses[questionIndex] = visibleIndex
                    //                    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { timer in
                    if canIncrement {
                        questionIndex += 1
                        currentSelection = responses[questionIndex]
                    }
                    else {
                        completion(.success(responses))
                    }
                }
                //                }
            label: {
                buttonTitleView(index: visibleIndex, width: arbitraryButtonWidth)
            }       // button label
            }       // ForEach
            .buttonStyle(.bordered)
            .font(.title)
        }
    }

    @State var idIsEnlarged = false
    static let unitScale = 1.0
    static let bigScale  = 1.25
    @State var boldfaced: Bool = false


    // MARK: - body
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 16) {
                Text("\(questionIndex+1)")
                    .font(.largeTitle)
                    .scaleEffect(idIsEnlarged ? Self.bigScale : Self.unitScale,
                                 anchor: .center)

                // Watch for the forced unwrap at UsabilityQuestion:subscript
                Text("\(UsabilityQuestion[questionIndex].text)")
                    .font(.title2)
            }
            .minimumScaleFactor(0.5)
            .padding()
            Divider()

            ratingsStack()
            Spacer()
        }
        .multilineTextAlignment(.leading)
//        .animation(.easeOut, value: questionIndex)
        .onDisappear() {
            completion(.success(
                responses
            ))
        }

        .toolbar {
            // TODO: Replace with ToolbarItem
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button("← Back") {
                    // No need to range-check, the .disabled does that.
                    responses[questionIndex] = currentSelection
                    completion( .success(responses) )
                    questionIndex -= 1
                    currentSelection = responses[questionIndex]
                }
                .disabled(!canDecrement)
            }

            ToolbarItemGroup(placement: .navigationBarTrailing) {

                ReversionButton(toBeSet: $showResetAlert)
                Button("Next →") {
                    responses[questionIndex] = currentSelection
                    completion( .success(responses) )
                    questionIndex += 1
                    currentSelection = responses[questionIndex]
                }
                .disabled(!canIncrement)
            }
        }
        .reversionAlert(on: $showResetAlert)
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

                UsabilityView(questionIndex: 0) { resultValue in
                    guard let array = try? resultValue.get() else {
                        print("UsabilityView should not fail.")
                        fatalError()
                    }

                    print("value for csv is",
                          array.map({ "\($0)" }).joined(separator: ",")
                    )
                }

            }
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
        }
    }
