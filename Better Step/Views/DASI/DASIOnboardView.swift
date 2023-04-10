//
//  DASIOnboardView.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/7/22.
//

import SwiftUI

let dasiOnboardContent: [CardContent] = {
    let retval = try! CardContent
        .contentArray(from: ["dasi-intro"])
    print(retval)
    assert(retval.areDistinct)
    return retval
}()


/// The first user-visible display in the DASI phase.
///
/// The ``SuccessValue`` as a ``ReportingPhase`` is `Void`.
struct DASIOnboardView: View, ReportingPhase {
    typealias SuccessValue = ()
    let completion: ClosureType


    init(completion: @escaping ClosureType) {
        self.completion = completion
    }

    // TODO: Add the forward/back bar.

    var body: some View {

        VStack {
            InterCarousel(content: dasiOnboardContent, reportEnded: {
                completion(.success(()))
                // Advance to the DASI questions.
            })
            .padding()
        }
    }
}

    struct DASIOnboardView_Previews: PreviewProvider {
        static var previews: some View {
            DASIOnboardView(completion: { _ in })
        }
    }
