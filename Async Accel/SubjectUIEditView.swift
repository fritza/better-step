//
//  SubjectUIEditView.swift
//  Async Accel
//
//  Created by Fritz Anderson on 3/28/22.
//

import SwiftUI
import Combine

/// An editor `Form` to collect a fresh patient/subject ID.
///
/// Sets the shared `SubjectID` observable class directly. The intended use case is:
/// - Upon first use of the app by an unknown user. "Unknown" is a question for the client code, ATW the need is signaled by a `nil` value for `SubjectID.shared.subjectID`.
/// - note: Also displays a `Text` row showing the value as understood iff the `DEBUG` compilation symbol is defined.
struct SubjectUIEditView: View {
    @EnvironmentObject var subjectID: SubjectID
    var body: some View {
        VStack {
            Form {
                // TODO: change "patient ID" to subject when needed.
                //       Heuristic: If DASI is available, it's a patient.
                Section("Enter your patient ID") {
                    TextField("Subject ID",
                              text: $subjectID.unwrappedSubjectID)
#if DEBUG
                    Text(subjectID.unwrappedSubjectID)
#endif
                }
            }
            // FIXME: Forced empirical height.
#if DEBUG
            .frame(height: 200)
#else
            .frame(height: 160)
#endif
        }
    }
}

final class JustADemo: ObservableObject {
    @State var editValue: String
    init(_ val: String) { editValue = val }
}

struct SubjectUIEditView_Previews: PreviewProvider {
    static var previews: some View {
        SubjectUIEditView()
            .environmentObject(SubjectID())
    }
}
