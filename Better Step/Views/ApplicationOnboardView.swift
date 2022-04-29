//
//  ApplicationOnboardView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/28/22.
//

import SwiftUI

struct ApplicationOnboardView: View {
    @EnvironmentObject var subjectIDObject: SubjectID

    enum WhereFocused: Hashable {
        case field
        case elsewhere
    }

    @State var localSubjectID: String = "" {
        didSet {
            // When the view-local subjectID changes, update the global subject.
            // TODO: Can't I refer to the subject directly?
            //        problem: The TextField wants a String, not a String?.
            if localSubjectID.isEmpty {
                subjectIDObject.subjectID = ""
                return
            }

            if localSubjectID != subjectIDObject.subjectID {
                subjectIDObject.subjectID = localSubjectID
            }
        }
    }

    init() {
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
                              text: $localSubjectID)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 200)
                    Text(String(describing: subjectIDObject.subjectID ?? "<n/a>"))
                    Spacer()
                }
                if !localSubjectID.isEmpty {
                    NavigationLink("Accept") {
                        SurveyContainerView()

                    }
                }
                else {
                    Text("Accept")
                        .foregroundColor(.gray)
                }
                Spacer()
                Text(localSubjectID).fontWeight(.medium)
            }
        }
    }
}

struct OnboardView_Previews: PreviewProvider {
    static var previews: some View {
        ApplicationOnboardView()
            .frame(width: .infinity)//, height: 300)
            .padding()
            .environmentObject(SubjectID.shared)
    }
}
