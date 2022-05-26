//
//  ClearableTextFieldView.swift
//  Better Step
//
//  Created by Fritz Anderson on 5/26/22.
//

import SwiftUI

struct ClearableTextFieldView: View {
    @Binding var content: String
    let title: String?

    init(string: Binding<String>, title: String? = nil) {
        _content = string
        self.title = title
    }


    var body: some View {
        HStack {
            // TODO: Doesn't TextField have a labelled variant?
            //            Spacer()
            if title != nil {
                Text(title!).font(.title3)
                Spacer(minLength: 24)
            }
            TextField("Subject ID:",
                      text: $content)
            .textFieldStyle(.roundedBorder)
        }
        .minimumScaleFactor(0.5)

    /*
     To make clearable:

     ZStack(alignment: .trailing) {
         TextField("IGNORED 1",
                   text: self.$emailAddress,
                   prompt: Text("reporting address"))
             .keyboardType(.emailAddress)
             .textFieldStyle(.roundedBorder)
//                        .focused($amSelected)
         Button(action: {
             self.emailAddress = ""

         }) {
             Image(systemName: "multiply.circle.fill")
                 .renderingMode(.template)
                 .foregroundColor(.gray)
                 .opacity(0.5)
         }
//                    .focused($amSelected)
         .padding([.trailing], 2)
     }

     */
    }
}

final class SubjectHolder: ObservableObject {
    var stringContent: String
    init(content: String) {
        stringContent = content
    }
}

enum FState: Hashable {
    case field, button
}

struct ClearableTextFieldView_Previews: PreviewProvider {
    @FocusState static var fieldIsFocused: FState?
    @State static var theString = "initial string"
    @StateObject static var shold: SubjectHolder = SubjectHolder(content: "state object")

    static var previews: some View {
        VStack {
            ClearableTextFieldView(string: $shold.stringContent)
                .focused($fieldIsFocused, equals: .field)
            Button("focus?") {
                fieldIsFocused = nil
            }
            Spacer()
            Text("Current value is “\(shold.stringContent)”")
            Spacer()
        }
        .padding()
    }
}

