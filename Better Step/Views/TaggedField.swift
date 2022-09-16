//
//  TaggedField.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/15/22.
//

import SwiftUI

struct TaggedField: View {

    @State var subject: String
    @State var showComment: Bool = false
    // ShowInstructions lags the subject string by one.
    // I think this has to do with _both_ updating the
    // backing string _and_ rendering conditioned on the
    // (existing pre-change?) value.
    @State var showInstructions: Bool = true
    let closeCallback: (String) -> Void

    var canSubmitText: Bool {
        return subject.trimmed?.isAlphanumeric ?? false
    }

//    @Binding var subject: String

    init(subject: String, callback: @escaping ((String) -> Void)) {
        self.subject = subject
        self.closeCallback = callback
    }

    var body: some View {
        VStack {
            ZStack(alignment: .trailing) {
                TextField("IGNORED 1",
                          text: $subject,
                          prompt: Text("reporting address"))
                    .keyboardType(.emailAddress)
                    .textFieldStyle(.roundedBorder)
    //                        .focused($amSelected)
                Button(action: {
                    subject = ""

                }) {
                    Image(systemName: "multiply.circle.fill")
                        .renderingMode(.template)
                        .foregroundColor(.gray)
                        .opacity(0.5)
                }
//                .onChange(of: subject, perform: { newText in
//                    closeCallback(subject.trimmed!)
//                    self.showComment = false
//                    self.showInstructions = !canSubmitText
//                })
                .onSubmit {
                    closeCallback(subject)
                }
                .padding([.trailing], 2)
            }

//            Button("Proceed") {
//                if canSubmitText {
//                    showComment = true
//                    closeCallback(subject.trimmed!)
//                    showInstructions = false
//                }
//            }
//            .disabled(!self.canSubmitText)
//            if showComment {
//                Text("Closed with \(subject)")
//                    .foregroundColor(.red)
//            }

//            if showInstructions {
//                Spacer()
//                Text("Your ID consists of letters and numbers, no punctuation or spacing.")
//                    .font(.body)
//                    .foregroundColor(.red)
//                    .lineLimit(6)
//                    .minimumScaleFactor(0.5)
//                    .frame(width: 300, height: 80)
//            }

        }
        .onSubmit(of: .text) {
            showComment.toggle()
        }
    }
}

final class HoldsAString: ObservableObject {
    @State var someSubjectID: String
    init(subject: String) {
        someSubjectID = subject
    }
}

struct TaggedField_Previews: PreviewProvider {
    static let holder = HoldsAString(subject: "Thirsday")
    static var content = ""
    static var previews: some View {
        NavigationView {
            TaggedField(subject: "Erewhon", callback: { result in
                print("Hello?", result)
            })
            .frame(width: 300, height: 48)
        }
    }
}
