//
//  SubjectUIEditView.swift
//  Async Accel
//
//  Created by Fritz Anderson on 3/28/22.
//

import SwiftUI

struct SubjectUIEditView: View {
    @State var idString: String {
        didSet {
            SubjectID.shared.subjectID =
            idString.isEmpty ? nil : idString
        }
    }

    init() {
        self.idString = SubjectID.shared.subjectID ?? ""
    }

    var body: some View {
        Form {
            Section("Subject ID") {
                TextField("Subject ID 2:", text: $idString)
                Text(idString)
            }
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
