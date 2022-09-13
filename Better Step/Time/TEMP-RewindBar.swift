//
//  TEMP-RewindBar.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/13/22.
//

import SwiftUI

struct TEMP_RewindBar: View {
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
                        } label: {
                            Label("S", systemImage: "arrow.backward.to.line")
                        }
                    }
                }
        }
    }
}

struct TEMP_RewindBar_Previews: PreviewProvider {
    static var previews: some View {
        TEMP_RewindBar()
    }
}
