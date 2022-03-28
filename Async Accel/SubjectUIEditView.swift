//
//  SubjectUIEditView.swift
//  Async Accel
//
//  Created by Fritz Anderson on 3/28/22.
//

import SwiftUI

/// An editor `Form` to collect a fresh patient/subject ID.
///
/// Sets the shared `SubjectID` observable class directly. The intended use case is:
/// - Upon first use of the app by an unknown user. "Unknown" is a question for the client code, ATW the need is signaled by a `nil` value for `SubjectID.shared.subjectID`.
/// - note: Also displays a `Text` row showing the value as understood iff the `DEBUG` compilation symbol is defined.
struct SubjectUIEditView: View {
    /// Working value for the subject ID, for the use of the `TextField`. Updates the shared `SubjectID` upon `didSet`.
    @State private var idString: String {
        didSet {
            SubjectID.shared.subjectID =
            idString.isEmpty ? nil : idString
        }
    }

    /// Create a new `SubjectUIEditView`. Clients have no direct connection to the value; the "return" value is in `SubjectID.shared.subjectID`.
    init() {
        self.idString = SubjectID.shared.subjectID ?? ""
    }

    var body: some View {
        VStack {
            Form {
                // TODO: change "patient ID" to subject when needed.
                //       Heuristic: If DASI is available, it's a patient.
                Section("Enter your patient ID") {
                    TextField("Subject ID", text: $idString)
                    #if DEBUG
                    Text(idString)
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

struct SubjectUIEditView_Previews: PreviewProvider {
    static var previews: some View {
//        SubjectID.shared.subjectID = "Groovy"
        SubjectID.clear()
        return SubjectUIEditView()
    }
}
