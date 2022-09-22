//
//  FailureView.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/21/22.
//

import SwiftUI

struct ConclusionView: View, ReportingPhase {
    var completion: ((Result<Void, Error>) -> Void)!
    var body: some View {
        VStack {
            Text("Congratulations, you're done.")
            Button("Complete") {
                completion(.failure(FileStorageErrors.NOS))
                // Why do I have to instantiate Void?
            }
        }
    }
}

struct FailureView: View, ReportingPhase {
    var completion: ((Result<Void, Error>) -> Void)!
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
        FailureView()
    }
}
