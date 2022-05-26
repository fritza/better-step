//
//  OnboardingView.swift
//  Better Step
//
//  Created by Fritz Anderson on 5/26/22.
//

import SwiftUI

// For now, assume the scheduling backbone takes care of whether the user is already on board.
struct OnboardingView: View {
    @AppStorage(AppStorageKeys.subjectID.rawValue) var globalSubject: String = ""

    @State var subjectIDString: String = "default"

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Thank you for participating in…")

            HStack {
                Spacer()
                Image(systemName: "figure.walk")
                    .resizable()
                    .frame(width: 100, height: 140)
                    .fixedSize(horizontal: true, vertical: true)
                Spacer()
            }
            .border(.green, width: 1.5)

//            Spacer(minLength: 40)
//                .border(.red, width: 1.5)
            Text("First, enter the participant ID number you received when you met with our staff.")
                .border(.orange, width: 1.5)
            ClearableTextFieldView(string: $subjectIDString)
            Spacer()
            HStack {
                Spacer()
                Button("Continue") {
                    // Set some kind of maybe invisible tab view.
                }
                .disabled(subjectIDString.count < 5)
                Spacer()
            }
        }
        .font(.body)
        .navigationTitle("Welcome")
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OnboardingView(subjectIDString: "")
                .padding()
        }
    }
}
