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

    @AppStorage(AppStorageKeys.subjectID.rawValue) var appStoredUserID: String = ""

    @State var localSubjectID: String = "fer"
    @State var fieldHasContent: Bool  = true

    init() {
//        let defaults = UserDefaults.standard
//        let storedID = defaults.string(forKey: AppStorageKeys.subjectID.rawValue) ?? ""
//        let isEmpty = storedID.isEmpty
        self.localSubjectID = ""
        self.fieldHasContent = true
    }

    var body: some View {
        NavigationView {
            VStack {
                // TODO:  The HStack should probably
                //        be the view, without a VStack.
                HStack {
                    Spacer()
                    Text("Subject ID:").font(.title3)
                    Spacer(minLength: 24)
                    TextField("Subject ID:",
                              text: self.$localSubjectID)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: self.localSubjectID) { newValue in
                            fieldHasContent = !newValue.isEmpty
                        }
                        .frame(width: 200)
                    Spacer()
                }
                if fieldHasContent {
                    NavigationLink("Accept", destination: {
                        Text("ActiveButton Pushed")
                    })
                }
                else {
                    Text("Accept")
                        .foregroundColor(.gray)
                }
                Spacer()
                Text(localSubjectID).fontWeight(.medium)
            }
        }
        .onAppear {
            localSubjectID = appStoredUserID
            fieldHasContent = localSubjectID.isEmpty
        }
        .onDisappear {
            appStoredUserID = localSubjectID
        }
    }
}

struct OnboardView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardView()
            .frame(width: .infinity)//, height: 300)
            .padding()
    }
}
