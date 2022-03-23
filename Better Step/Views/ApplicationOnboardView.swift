//
//  ApplicationOnboardView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/28/22.
//

import SwiftUI

struct ApplicationOnboardView: View {
    enum WhereFocused: Hashable {
        case field
        case elsewhere
    }

    @State var localSubjectID: String = "fer" {
        didSet {
            // When the view-local subjectID changes, update the global subject.
            // TODO: Can't I refer to the subject directly?
            //        problem: The TextField wants a String, not a String?.
            let rootSubjectID = RootState.shared.subjectIDSubject.value
            if rootSubjectID == nil || localSubjectID != rootSubjectID {
                RootState.shared.subjectIDSubject.send(localSubjectID)
            }
        }
    }
//    @State var fieldHasContent: Bool  = false

    init() {
        self.localSubjectID = RootState.shared.subjectIDSubject.value ?? ""
//        self.fieldHasContent = false
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    // Label and field.
                    // TODO: Doesn't TextField have a labelled variant?
                    Spacer()
                    Text("Subject ID:").font(.title3)
                    Spacer(minLength: 24)
                    TextField("Subject ID:",
                              text: self.$localSubjectID)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 200)
                    Text(String(describing: RootState.shared.subjectIDSubject.value ?? "<n/a>"))
                    Spacer()
                }
                if !localSubjectID.isEmpty {
                    NavigationLink("Accept", destination: {

                        // FIXME: Why does app onboard set DASI state?
                        SurveyContainerView()
                            .environmentObject(DASIPages(.landing))


                        //                        Text("ActiveButton Pushed")
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
            guard let globalID = RootState.shared.subjectIDSubject.value else {
                fatalError()
            }
            localSubjectID = globalID
//            fieldHasContent = !localSubjectID.isEmpty
        }
        .onDisappear {
//            appStoredUserID = RootState.
        }
    }
}

struct OnboardView_Previews: PreviewProvider {
    static var previews: some View {
        ApplicationOnboardView()
            .frame(width: .infinity)//, height: 300)
            .padding()
    }
}
