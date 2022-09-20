//
//  OnboardContainerView.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/19/22.
//

import SwiftUI


/// Workflow container for onboarding views.
///
/// Unlike the other containers, this _might_ not be a `ReportingPhase`.
struct OnboardContainerView: View, ReportingPhase {
    @State private var correctStage: Int?
    var finishedInterstitialInfo: InterstitialInfo
    var completion: ((Result<Void, Error>) -> Void)!

    init(completion: (Result<(), Error>) -> Void) {
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
            correctStage = OnboardStages.firstGreeting.rawValue
        }
        else {
            correctStage = OnboardStages.laterGreeting.rawValue
        }
    }

    enum OnboardStages: Int {
        case firstGreeting // include testing subjectID.
        case laterGreeting
        case greetingHandoff
    }

    var body: some View {
        TabView(selection: $correctStage) {
            ApplicationOnboardView() { result in
                if let finished = try? result.get() {
                    SubjectID.id = finished
                    completion(.success(()))
//                    correctStage = OnboardStages.greetingHandoff.rawValue
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

struct OnboardContainerView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardContainerView() {
            _ in print("nothing to do")
        }
    }
}
