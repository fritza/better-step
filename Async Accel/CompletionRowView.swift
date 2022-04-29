//
//  CompletionRowView.swift
//  Async Accel
//
//  Created by Fritz Anderson on 3/30/22.
//

import SwiftUI

struct StatusItem: Identifiable {
    let completed   : Bool
    let title       : String
    let content     : String

    var id: String { title + content }
}

let statusItems = [
    StatusItem(completed: true, title: "First", content: "The first task was completed."),
    StatusItem(completed: false, title: "Second", content: "The SECOND task was not completed. Return to that phase of the test and complete it."),

    ]

struct CompletionRowView: View {
    let completed   : Bool
    let title       : String
    let content     : String

    init(item: StatusItem) {
        (completed, title, content) = (item.completed, item.title, item.content)
    }

    var badge: some View {
        if completed {
            return Image(systemName: "checkmark.circle.fill")
                .symbolRenderingMode(.monochrome)
                .foregroundColor(.green)
        }
        else {
            return Image(systemName: "exclamationmark.triangle.fill")
                .symbolRenderingMode(.monochrome)
                .foregroundColor(.yellow)
        }
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            badge
                .frame(width: 20)
            VStack(alignment: .leading) {
                Text(title  ).font(.headline)
                Text(content)
                    .lineLimit(4)
                    .font(.body    )
            }
        }
    }
}

struct CompletionRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 10) {
            Spacer()
            CompletionRowView(item: statusItems[0])
            CompletionRowView(item: statusItems[1])
            Spacer()
        }
        .frame(maxHeight: Double(statusItems.count) * 100.0)
        .environmentObject(SubjectID())
    }
}

