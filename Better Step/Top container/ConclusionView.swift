//
//  ConclusionView.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/21/22.
//

import SwiftUI
import ActivityKit

// MARK: - Conclusion View
/// A view that annpunces the successful completion of the workflow.
///
/// Its ``SuccessValue`` as a ``ReportingPhase`` is `Void`.
struct ConclusionView: View, ReportingPhase {
    typealias SuccessValue = Void
    let completion: ClosureType
    let cardContent: CardContent
    
    init(jsonBaseName: String, _ closure: @escaping ClosureType) {
        let contentRecord = try! CardContent.contentArray(from: jsonBaseName)
        self.cardContent = contentRecord.first!
        completion = closure
    }

    var body: some View {

#warning("DON'T SUBMIT, DON'T NOTE COMPLETION")
        // until the completion closure below;
        // or put the completion shores in the container's
        // closure.


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
