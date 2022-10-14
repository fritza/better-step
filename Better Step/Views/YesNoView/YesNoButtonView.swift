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

    var body: some View {
        Button(
            action: {
                completion(.success(()))
            },
            label: {
                Text(self.title.asChecked(isChecked)
                )
                .font(.title2)
                .fontWeight(.semibold)
            })
        .frame(minWidth: 320, minHeight: 56.0)
        .background {
            Capsule(style: .continuous)
                .fill(
                    Color(white: 0.75) //, opacity: 0.25)
                )
        }
    }
}



struct YesNoButtonView_Previews: PreviewProvider {
    final class TapCount: ObservableObject {
        @Published var countOne: Int = 0

        @Published var countTwo: Int = 0
    }

    static let content = TapCount()

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
