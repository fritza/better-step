//
//  YesNoButtonView.swift
//  Better Step
//
//  Created by Fritz Anderson on 10/14/22.
//

import SwiftUI


extension String {
    /// Prepend a Unicode "✓ " to this `String if `checked` is `true`.
    func asChecked(_ checked: Bool) -> String {
        // TODO: Empirical checkmark width is a bad idea
        (checked ? "✓ " : "   ") + self
    }
}

/// A button-like `View` that presents text (expected **Yes** or **No**) that calls back when it is tapped.
///
/// The ``SuccessValue`` as a ``ReportingPhase`` is `Void`.
///
/// The client gets norification of the tap, and knows whether it is **Yes** or **No** because the completion closure  knows which button the tap belongs to.
struct YesNoButtonView: View, ReportingPhase {
    typealias SuccessValue = ()
    let title: String
    let isChecked: Bool

    let completion: ClosureType

    init(title: String, checked: Bool,
         completion: @escaping ClosureType) {
        self.title = title
        isChecked = checked
        self.completion = completion
    }

    let lightGray = Color(white: 0.875, opacity: 1.0)
    @GestureState var buttonIsHeld: Bool = false

    var buttonishGesture: some Gesture {
        let retval = TapGesture(count: 1)
            .updating($buttonIsHeld) { v, s, t in
                s.toggle()
            }
            .onEnded { _ in
                if buttonIsHeld {
                    completion(.success(()))
                }
            }
        return retval
    }

    var body: some View {
        ZStack(alignment: .center, content: {

            Capsule(style: .continuous)
                .fill(
                    Color(white:  buttonIsHeld ? 0.25 : 0.75)
                        .opacity(0.9)
                )
            Text(self.title.asChecked(isChecked)
            )
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.accentColor)
        })
        .frame(width: 320, height: 56)
//        .gesture(buttonishGesture)
        .onTapGesture(count: 1, perform: {
            completion(.success(()))
        })
    }

    /*
    var body: some View {
        Button(
            action: {
                completion(.success(()))
            },
            label: buttonLabelView()
            )
//            label: {
//                Text(self.title.asChecked(isChecked)
//                )
//                .font(.title2)
//                .fontWeight(.semibold)
//            })
//        .border(Color.red)
//        .frame(width: 320, height: 56)
//        .background {
//            Capsule(style: .continuous)
//                .fill(
//                    Color(white: 0.75) //, opacity: 0.25)
//                )
        }
    }
     */
}



struct YesNoButtonView_Previews: PreviewProvider {
    // NOTE: Had been ObservableObject, apparently not needed for @Published.
    // BUT : Using ObeervableObject anyway to experiment with @StateObject.
    final class TapCount: ObservableObject {
        @Published var countOne: Int = 0
        @Published var countTwo: Int = 0
    }

//    static let content = TapCount()
    @StateObject static var content = TapCount()

    static var previews: some View {
        ZStack {
                VStack {
                    Color.red
                    Color.blue
                    Color.green
                    Color.orange
                    Color.gray
                    Color.teal
                }
                .rotationEffect(Angle(degrees: 45))
            VStack {
                Text("TAP \(content.countOne)")
                YesNoButtonView(title: "Yes",
                                checked: true,
                                completion: {
                    _ in
                    content.countOne += 1
                }
                )

                Spacer(minLength: 12)
                YesNoButtonView(title: "No",
                                checked: false,
                                completion: {
                    _ in
                    content.countTwo += 1

                })
                Text("TAP \(content.countTwo)")
                Spacer(minLength: 250)
            }
            .frame(width: 320.0, height: 44.0 * 2.0 + 12.0)
        }
    }
}
