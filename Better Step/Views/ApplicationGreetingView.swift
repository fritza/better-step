//
//  ApplicationGreetingView.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/16/22.
//

import SwiftUI


// MARK: - ApplicationGreetingView
/// Initial display for runs that already have SubjectIDs
/// - note: This view is contained in a `NavigationView` within ``TopContainerView``. It _wraps_ ``GenericInstructionView``

struct ApplicationGreetingView: View, ReportingPhase {
    typealias SuccessValue = Void
    let completion: ClosureType
    
    #warning("put greeting view content into a .json")
    static let upperText = """
You’ll be repeating the timed walks you did last time. There will be no need to repeat the surveys you completed the first time you used [OUR APP].
"""
    static let title = "Welcome Back!"
    static let systemImageName = "figure.walk"
    static let lowerText = """
Tap “Continue” to proceed.
"""
    init(_ closure: @escaping ClosureType) {
        self.completion = closure
    }
    
    var body: some View {
        GenericInstructionView(
            titleText: Self.title,
            // TODO: A way to pass an additon of styled Text.
            upperText: Self.upperText,
            sfBadgeName: Self.systemImageName,
            lowerText: Self.lowerText,
            proceedTitle: "Continue",
            proceedClosure: {
                self.completion(
                    .success(
                        ()
                    )
                )})
        .padding()
    }
}

struct ApplicationGreetingView_Previews: PreviewProvider {
    @State static var isInitial = false
    
    @State static var message: String = "Initial"
    
    static func proceedTapped() {
        Self.isInitial.toggle()
        message = "Tapped."
    }
    
    static var previews: some View {
        VStack {
            Text(Self.message)
            ApplicationGreetingView() {_ in
                Self.proceedTapped()
            }
        }
    }
}
