//
//  InstructionPageView.swift
//  Better Step
//
//  Created by Fritz Anderson on 4/6/22.
//

import SwiftUI

// FIXME: What NavigationView does InstructionPageView inhabit?

/// A `View` that presents the `Text`/`Image`/whatever elements of the instruction page.
struct InstructionPageView: View {
    let content: [InstructionElement]

    var body: some View {
        VStack(alignment: .leading, spacing: 20.0) {
            ForEach(content) {
                $0.rendering
            }
        }
    }
}

// For Preview use only.
let sourceStrings: [String] = [
    "title", "Measuring your walk",
    "body" , "We want to know how hard your heart works, when it's challenged.",
    "body" , "We'll ask you to perform two activities. Your phone will track how you move as you perform them. When you're done, **Home Steps** will send your report to your caregivers for evaluation.",
    
    "image", "STBar.jpeg",
    "body", "• You'll walk for _two minutes_ at your regular pace to see how you manage moderate tasks such as in your daily life.",
    "body", "• Then you'll take another two-minute walk, putting as much effort into it as you comfortably can. Comparing",
]


struct InstructionPageView_Previews: PreviewProvider {
    static let sourceElements: [InstructionElement] = {
        var retval: [InstructionElement] = []
        for index0 in stride(from: 0, to: sourceStrings.count, by: 2) {
            let (type, value) = (String(sourceStrings[index0]), String(sourceStrings[index0 + 1]))
            let element = InstructionElement(roleAndContent: [type, value])
            retval.append(element)
        }

        return retval
    }()

    static var previews: some View {
        NavigationView {
            InstructionPageView(content: sourceElements)
            // FIXME: in this case, use the title as the navigation title.
                .navigationTitle("Welcome")
                .padding()
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button("Next →") {

                        }
                        gearBarItem()
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("← Back") {

                        }

//                    ToolbarItem(id: "Next", placement: .navigationBarTrailing, showsByDefault: true) {
//                        Button("Next") {
//
//                        }
//                        gearBarItem()
//                    }
//                        ReversionButton(shouldShow: $resetAlertVisible)
                    }
                }
        }
    }
}
