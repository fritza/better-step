//
//  OnboardContainerView.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/19/22.
//

import SwiftUI


/// Workflow container for onboarding views.
struct OnboardContainerView: View, ReportingPhase {
    @State private var correctTask: Int?
    @State private var shouldWarnOfReversion: Bool = false
    var finishedInterstitialInfo: InterstitialInfo

    typealias SuccessValue = String
    let completion: ClosureType

    init(completion: @escaping ClosureType) {
        self.completion = completion
        finishedInterstitialInfo = InterstitialInfo(
            id: 0,
            intro: """
You’ll be repeating the timed walks you did last time. There will be no need to repeat the surveys you completed the first time you used [OUR APP].
""",
            proceedTitle: "Continue",
            pageTitle: "Welcome Back",
            systemImage: "figure.walk"
        )

        if SubjectID.id == SubjectID.unSet {
            correctTask = OnboardTasks.firstGreeting.rawValue
        }
        else {
            correctTask = OnboardTasks.laterGreeting.rawValue
        }
    }

    enum OnboardTasks: Int {
        case firstGreeting // include testing subjectID.
        case laterGreeting
        case greetingHandoff
    }

    #if true

    @State var workingString = "xxx"

    var body: some View {
        NavigationView {
            ApplicationOnboardView(string: $workingString) { result in
                // Success result is a String with the proposed subject ID.
                // The received ID.

                #warning("sep/responsibility between OnboardContainer and AppOnboard View")
                // TODO: This container should be the setter for SubjectID.
                //       Instead it's set in the onboard view.
                if let finished = try? result.get() {
//                    SubjectID.id = finished
                    completion(.success(finished))

                    // THIS SHOULD TRIGGER THE WALK PHASE
//                    correctTask = OnboardTasks.greetingHandoff.rawValue
                }
                // FIXME: what happens upon failure?
            }
            .reversionToolbar($shouldWarnOfReversion)
            .reversionAlert(next: $correctTask,
                            shouldShow: $shouldWarnOfReversion)

        }
        .padding()
    }
    #else
    var body: some View {
        NavigationView {

        TabView(selection: $correctStage) {
            ApplicationOnboardView() { result in
                if let finished = try? result.get() {
                    SubjectID.id = finished
                    completion(.success(()))
                }
                // FIXME: what happens upon failure?
            }
            .tag(OnboardStages.firstGreeting.rawValue)

            InterstitialPageView(info: finishedInterstitialInfo) {
                completion(.success(()))
            }
            .tag (OnboardStages.laterGreeting.rawValue)

        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
        }
    #endif
}

struct OnboardContainerView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardContainerView() {
            _ in print("nothing to do")
        }
    }
}
