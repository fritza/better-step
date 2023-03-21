//
//  OnboardContainerView.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/19/22.
//

import SwiftUI


/// Workflow container for onboarding views.
///
/// Its ``SuccessValue`` as a ``ReportingPhase`` is `String`.
/// - note: This view contains ``ApplicationOnboardView``
///     It is ultimately contained in a `NavigationView` in ``TopContainerView``
struct OnboardContainerView: View, ReportingPhase {
    typealias SuccessValue = String
    let completion: ClosureType
    // SuccessValue contains the discovered SubjectID.
    // It is passed to the container view, which sets
    // SubjectID.id.

    init(completion: @escaping ClosureType) {
        self.completion = completion
        let initialTask: OnboardTasks =  SubjectID.isSet
        ?   .laterGreeting
        :   .firstGreeting
    }

    enum OnboardTasks: Int {
        case firstGreeting // include testing subjectID.
        case laterGreeting
        case greetingHandoff
    }
    @State var workingString = SubjectID.id
    
    var body: some View {
        ApplicationOnboardView(string: $workingString) {
            string in
            // Success result is a String with the proposed subject ID.
            // The received ID.
            
            if let finished = try? string.get() {
                // Propagate Onboerd View's (upstream)
                // result to TopContainerView (downstream)
                // which will set SubjectID.id
                completion(.success(finished))
            }
            // FIXME: what happens upon failure?
        }
        .padding()
    }
}

struct OnboardContainerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Subject ID: '\(SubjectID.id)'")
                .font(.caption).foregroundColor(.red)
            OnboardContainerView() {
                _ in print("nothing to do")
            }
        }
    }
}
