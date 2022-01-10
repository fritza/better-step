//
//  EmailFormView.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/25/21.
//

import SwiftUI
//import Combine

struct EmailFormView: View {
    @FocusState private var amSelected: Bool
    @Binding var emailAddress: String
    let title: String
    let keyboardType: UIKeyboardType

    init(title: String,
         keyboard: UIKeyboardType = .emailAddress,
         address: Binding<String>) {
        self.title = title
        self.keyboardType = keyboard
        self._emailAddress = address
        //        self.$emailAddress = address
    }

    var body: some View {
        GeometryReader { proxy in
            HStack {
                Text(title)
                    .frame(width: proxy.size.width * 0.25,
                           alignment: .leading)
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
            }
        }
    }
}

final class AddressHolder: ObservableObject {
    @AppStorage("emailAddress") var email: String = ""
}

struct EmailFormView_Previews: PreviewProvider {
    static var addrHold = AddressHolder()
    static var previews: some View {
        VStack {
            EmailFormView(
                title: "Report:",
                address: addrHold.$email)
                .frame(height: 80)
            Text("stored = \(addrHold.email)")
            Spacer()
        }.padding()
    }
}
