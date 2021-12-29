//
//  EmailFormView.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/25/21.
//

import SwiftUI
//import Combine

struct EmailFormView: View {
//    @FocusState private var amSelected: Bool
//    @Binding var addressContent: EmailClient
    @EnvironmentObject var config: Configurations
    let title: String
    let offset: CGFloat
    let keyboardType: UIKeyboardType

    init(title: String,
         fieldOffset: CGFloat = 64,
         keyboard: UIKeyboardType = .emailAddress) {
        self.title = title
        self.offset = fieldOffset
        self.keyboardType = keyboard
    }

    var body: some View {
        HStack {
            Text(title)
                .frame(width: offset)
            TextField("IGNORED 1",
                      text: $config.emailAddress,
                      prompt: Text("reporting address"))
                .keyboardType(.emailAddress)
            Button(action: { config.emailAddress = "" }) {
                Image(systemName: "multiply.circle.fill")
                    .renderingMode(.template)
                    .foregroundColor(.gray)
                    .opacity(0.5)
            }
                .padding([.trailing], 0)
//                .opacity(amSelected ? 0.5 : 0.0)
                // Shift the clear button to align with the
                // trailing edge of the stepper.
//            }
        }
    }
}

struct EmailFormView_Previews: PreviewProvider {
    static let config: Configurations = {
        return Configurations(startingEmail: "", duration: 2)
    }()

    static var previews: some View {
        VStack {
            EmailFormView(title: "Report:"
//                         , fieldOffset: 72
            )
                .frame(width: 360, height: 60)
                .environmentObject(config)
        }
    }
}
