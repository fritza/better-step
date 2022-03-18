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
@State private var showingAlert = false

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("Instructions")
                Spacer()
                HStack {
                    Spacer()
                    Button("Cancel", role: .cancel, action: {showingAlert = true})
                    Spacer()
                    Button("Send", action: {})
                    Spacer()
                }
                Spacer()
            }
            .alert("Sure?", isPresented: $showingAlert, actions: {
                Button("Yes.") {
                    showingAlert = false
                }
            })
            .navigationTitle("Reporting")
        }
    }
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView()
    }
}
