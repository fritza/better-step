//
//  CompletionDisplayView.swift
//  Async Accel
//
//  Created by Fritz Anderson on 3/30/22.
//

import SwiftUI


struct CompletionDisplayView: View {
    let statusItems: [StatusItem]

    init(items: [StatusItem]) {
        statusItems = items
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            ForEach(statusItems) { item in
                CompletionRowView(item: item)
                Divider()
            }
            Spacer()
        }
    }
}

struct CompletionDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        CompletionDisplayView(items: statusItems)
            .padding()
            .environmentObject(SubjectID.shared)
        }
    }
