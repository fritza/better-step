//
//  ReportView.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/19/21.
//

import SwiftUI
let reportNarrative = """
This part of the app forwards your contributions to the investigation group at The University of Chicago Medicine.

Only UCM staff should operate this facility
"""

struct ReportView: View {
    var body: some View {
        GenericInstructionView(titleText: "Report",
                               bodyText: reportNarrative, sfBadgeName: "doc.text",
        proceedTitle: "Send it in") {

        }
        .padding(32)
    }
}
//
//struct ReportView: View {
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView()
    }
}
