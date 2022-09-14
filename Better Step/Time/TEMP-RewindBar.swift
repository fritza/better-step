//
//  TEMP-RewindBar.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/13/22.
//

import SwiftUI

struct TEMP_RewindBar: View {
    @State private var explanationVisible = false

    @State private var content = "No"
    var body: some View {
        NavigationView {
            Text(content)
                .font(.largeTitle)
                .navigationTitle("Sample title")
                .toolbar {
                    ToolbarItem(/*placement: .navigationBarTrailing*/) {
                        Button {
                            content = "Yes"
                            explanationVisible = true
                        } label: {
                            Label("S", systemImage: "arrow.backward.to.line")
                        }
                    }
                }
        }
        .alert("Starting Over", isPresented: $explanationVisible) {
            Button("Cancel", role: .cancel)      { explanationVisible.toggle() }
            Button("Reset" , role: .destructive) { explanationVisible.toggle() }
        }
    message: {
        Text("This button removes everything but the subject ID and starts over.") }
    }
}

struct TEMP_RewindBar_Previews: PreviewProvider {
    static var previews: some View {
        TEMP_RewindBar()
    }
}
