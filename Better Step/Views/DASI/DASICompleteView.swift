//
//  DASICompleteView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/28/22.
//

import SwiftUI

let dasiCompletionContent = try! CardContent.contentArray(from: ["dasi-complete"]).first!


fileprivate let completionText = """
You have completed the survey portion of this exercise.
"""

fileprivate let startIncompleteText = """

NOTE: You still have
"""
fileprivate let endIncompleteText = """
 questions yet to answer.
"""

// FIXME: Should there be a Back button?

/// The screen presented to the user at the end of the DASI phase
///
/// The ``SuccessValue`` as a ``ReportingPhase`` is `Void`.
struct DASICompleteView: View, ReportingPhase {
    typealias SuccessValue = DASIResponseList

    /// `NSError` domain for trying to report with incomplete responses.
    /// the error's `code` is the DASI question (intended to be
    /// the first missing response) to be displayed
    static let pageBackErrorDomain = "DASI.pageBack"

    let completion: ClosureType
    @EnvironmentObject var dasiResponses: DASIResponseList
    init(responses: DASIResponseList,
         _ completion: @escaping ClosureType
         ) {
        self.completion = completion
//        self.dasiResponses = responses
    }

    var body: some View {
        VStack {
            SimplestCard(content: dasiCompletionContent) {
                completion(.success(dasiResponses))
            }
        }.padding()
    }
}

struct DASICompleteView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DASICompleteView(responses: DASIResponseList()) {
                _ in
            }
        }
        .environmentObject(DASIResponseList())
    }
}
