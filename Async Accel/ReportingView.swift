//
//  ReportingView.swift
//  Async Accel
//
//  Created by Fritz Anderson on 3/30/22.
//

import SwiftUI

struct ReportingView: View {
    let completionItems: [StatusItem]

    // How are we going to do this, with no actual task?
    private static func fillCompletionList() -> [StatusItem] {
        let theOneItem: StatusItem
        if ContentView.hasCollected {
            theOneItem = StatusItem(
                completed: true, title: "Accelerometry",
                content: "You’ve tried collecting accelerometery.")
        }
        else {
            theOneItem = StatusItem(
                completed: false, title: "Acelerometry",
                content: "You haven’t tried accelerometry yet.")
        }
        return [theOneItem]
    }

    var allComplete: Bool {
        completionItems.allSatisfy(\.completed)
    }

    init() {
        completionItems = Self.fillCompletionList()
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("Data collection \(allComplete ? "is now" : "is not yet") complete.")
                .font(.headline)
                CompletionDisplayView(items: completionItems)
                    .frame(height: 120)
                    .padding()
            }
            .navigationTitle("Reporting")
        }
    }
}

struct ReportingView_Previews: PreviewProvider {
    static var previews: some View {
            ReportingView()
        .environmentObject(SubjectID())
    }
}
