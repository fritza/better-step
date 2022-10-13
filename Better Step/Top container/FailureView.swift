//
//  FailureView.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/21/22.
//

import SwiftUI

struct ConclusionView: View, ReportingPhase {
    typealias SuccessValue = Void
    let completion: ClosureType
    init(_ closure: @escaping ClosureType) {
        completion = closure
    }

    var body: some View {
        VStack {
            Text("Congratulations, you're done.")
            Button("Complete") {
                completion(.failure(AppPhaseErrors.NOS))
                // Why do I have to instantiate Void?
            }
        }
    }
}

struct FailureView: View, ReportingPhase {
    typealias SuccessValue = Void
    let completion: ClosureType
    init(_ closure: @escaping ClosureType) {
        completion = closure
    }

    var body: some View {
        VStack {
            Text("""
If you’re seeing this, the last thing you did resulted in a programming error. Let fritza@uchicago.edu know.
""")
        }
        .navigationBarTitle("App Failed")
    }
}

struct FailureView_Previews: PreviewProvider {
    static var previews: some View {
        FailureView() {
            _ in
        }
    }
}
