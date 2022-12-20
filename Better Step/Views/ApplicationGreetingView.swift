//
//  ApplicationGreetingView.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/16/22.
//

import SwiftUI

private var forPreview = false

/// Initial display for runs that already have SubjectIDs
struct ApplicationGreetingView: View, ReportingPhase {
    typealias SuccessValue = Void
    let completion: ClosureType
    
    static let upperText = """
You’ll be repeating the timed walks you did last time. There will be no need to repeat the surveys you completed the first time you used [OUR APP].
"""
    static let title = "Welcome Back!"
    static let systemImageName = "figure.walk"
    static let lowerText = """
Tap “Continue” to proceed.
"""
    init(_ closure: @escaping ClosureType) {
        assert(forPreview || (SubjectID.id != SubjectID.unSet))
        self.completion = closure
    }
    
    var body: some View {
        GenericInstructionView(
            titleText: Self.title,
            // TODO: A way to pass an additon of styled Text.
            bodyText: Self.upperText,
            sfBadgeName: Self.systemImageName,
            proceedTitle: "Continue",
            proceedClosure: {
                self.completion(
                    .success(
                        ()
                    )
                )})
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
