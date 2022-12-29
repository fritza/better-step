//
//  TaggedField.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/15/22.
//

import SwiftUI

/// A `TextField` that adds a clear button (**⊗**).
///
/// The `String` result is observed by a `Binding`.
struct TaggedField: View {
    @Binding var stringInProgress: String

    @State var showComment: Bool = false
    // ShowInstructions lags the subject string by one.
    // I think this has to do with _both_ updating the
    // backing string _and_ rendering conditioned on the
    // (existing pre-change?) value.
    @State var showInstructions: Bool = true
    var canSubmitText: Bool {
        return stringInProgress.trimmed?.isAlphanumeric ?? false
    }

    init(string: Binding<String>) {
        self._stringInProgress = string
    }

    var body: some View {
        VStack {
            ZStack(alignment: .trailing) {
                TextField("IGNORED 1",
                          text: $stringInProgress,
                          prompt: Text("Your Subject ID"))
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.asciiCapable)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                Button(action: {
                    stringInProgress = ""
                }) {
                    Image(systemName: "multiply.circle.fill")
                        .renderingMode(.template)
                        .foregroundColor(.gray)
                        .opacity(0.5)
                }
                .padding([.trailing], 2)
            }
        }
    }
}

fileprivate final class HoldsAString: ObservableObject {
    @State var someSubjectID: String
    init(subject: String) {
        someSubjectID = subject
    }
}

struct TaggedField_Previews: PreviewProvider {
//    fileprivate static let holder = HoldsAString(subject: "Thursday")
//    @State static var content = "Erewhon"
    @StateObject fileprivate static var holder = HoldsAString(subject: "Saturday")
    static var previews: some View {
        NavigationView {
            VStack {
                TaggedField(string: holder.$someSubjectID)
                    .frame(width: 300, height: 48)
                Text("current: '\(holder.someSubjectID)'")
            }
        }
    }
}
