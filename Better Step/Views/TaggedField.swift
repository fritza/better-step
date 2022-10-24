//
//  TaggedField.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/15/22.
//

import SwiftUI

struct TaggedField: View {
    //}, ReportingPhase {
//    typealias SuccessValue = String
//    let completion: ClosureType

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

    init(string: Binding<String>
//         , callback: @escaping ClosureType)
    )
    {
//        self.subject = subject
        self._stringInProgress = string
//        self.completion = callback
    }

    var body: some View {
        VStack {
            ZStack(alignment: .trailing) {
                // Upon <return>, the enclosing class
                // will get .onSubmit, and should get its
                // answer string through the "string" binding.

                // The enclosing class is expected to have a
                // submit button as well. Again, use the bound
                // "string".

                // Both handlers must report the final value up
                // the callback chain.

                // JUST DECIDE: The Onboard Container should set SubjectID
                TextField("IGNORED 1",
                          text: $stringInProgress,
                          prompt: Text("reporting address"))
                    .keyboardType(.emailAddress)
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
    fileprivate static let holder = HoldsAString(subject: "Thursday")
    @State static var content = "Erewhon"
    static var previews: some View {
        NavigationView {
            TaggedField(string: $content)
            .frame(width: 300, height: 48)
        }
    }
}
