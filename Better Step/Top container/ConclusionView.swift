//
//  ConclusionView.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/21/22.
//

import SwiftUI
import ActivityKit

// MARK: - Conclusion View
/*
 This is a bit tricky, because submission had been hard-wired into PhaseStorage as soon as all phases had presented their CSV content.
 This was very robust and worked well. Now the app relies on correct a ReportingPhase callback from ConclusionView,

 If a second page were added to ConclusionView,
 the callback would have to be at the end of the _FIRST,_ not at the end of the phase.
 BUT there's  a second state to ConclusionView, the release from the last card and back to the first phase.
 */


/// A view that announces the advancement of the workflow.
///
/// It assumes only a single instance of ``SimplestCard``. If the requirement changes to two cards, Reporting: GO, then Return to initial GO; this `View` must be rewritten as an ``InterCarousel``.
///
/// Its reporting closure yields a ``Handoff``, which has cases for just-submit and just-loop back, which are not yet used.

struct ConclusionView: View, ReportingPhase {
    typealias SuccessValue = Void
    let completion: ClosureType
    let cardContent: CardContent

//    @State private var currentState: Handoff
    
    init(jsonBaseName: String,
//         state: Handoff = .neither,
         _ closure: @escaping ClosureType) {
        let contentRecord = try! CardContent.contentArray(from: jsonBaseName)
        self.cardContent = contentRecord.first!
//        currentState = state
        completion = closure
    }

    var body: some View {
        VStack {
            Spacer()
            SimplestCard(content: cardContent, tapped: {
                completion(
                    .success(())
                )
            })
            .padding()
        }
    }
}

struct ConclusionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ConclusionView(jsonBaseName: "conclusion") {
                _ in
                print(#function, "completion delivered.")
            }
        }
    }
}
