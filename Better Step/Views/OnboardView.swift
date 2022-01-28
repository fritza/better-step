//
//  OnboardView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/28/22.
//

import SwiftUI

struct OnboardView: View {
    enum WhereFocused: Hashable {
        case field
        case elsewhere
    }

//    @State private var subjectID: String
    @FocusState var keyboardIsLive: WhereFocused?
    @EnvironmentObject var globalState: GlobalState
    @AppStorage(AppStorageKeys.subjectID.rawValue) var appStoredUserID: String = ""

    init() {
        // FIXME: There has to be a better way to set this.
    }

    var body: some View {
        GeometryReader { proxy in
            VStack {
                Text("Step Test")
                    .font(.largeTitle)
                Spacer()

                HStack {
                    Text("Start by entering the ID for the next subject.")
                    Spacer()
                }
                Spacer()

                HStack {
                    Text("Subject ID:")
                    Spacer()
                    TextField("Subject ID:",
                              text: $globalState.subjectID)
                        .keyboardType(.default)
                        .frame(width: proxy.size.width * 0.6)
                        .focused($keyboardIsLive, equals: .field)
                }
                Spacer()

                Button("Submit") {
                    // Shouln't need to reset globalState as the text edit updated it already.
//                    globalState.clear(newUserID: subjectID)
                    keyboardIsLive = nil
                }
                .focused($keyboardIsLive, equals: .elsewhere)
                Spacer()
                Text("Globals: ")
                +
                Text(globalState.subjectID)
                    .fontWeight(.semibold)

//                Spacer(minLength: 5)
            }
            .onSubmit(of: .text) {
                keyboardIsLive = .elsewhere
                // Shouln't need to reset globalState as the text edit updated it already.
//                globalState.clear(newUserID: subjectID)
            }
            .onAppear {
                keyboardIsLive = .elsewhere
            }
            .padding()
        }
    }
}

struct OnboardView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardView()
            .frame(width: .infinity, height: 300)
            .padding()
            .environmentObject(GlobalState())
    }
}
