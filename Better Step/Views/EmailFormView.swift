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
    let keyboardType: UIKeyboardType

    init(title: String, keyboard: UIKeyboardType = .emailAddress) {
        self.title = title
        self.keyboardType = keyboard
    }

    var body: some View {
        GeometryReader { proxy in
            HStack {
                Text(title)
                    .frame(width: proxy.size.width * 0.25,
                           alignment: .leading)
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
            }
        }
    }
}

struct EmailFormView_Previews: PreviewProvider {
    static let config: Configurations = {
        return Configurations(startingEmail: "", duration: 2)
    }()

    static var previews: some View {
        VStack {
            EmailFormView(title: "Report:")
                .frame(width: 360, height: 60)
                .environmentObject(config)
        }
    }
}
