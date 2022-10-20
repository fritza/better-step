//
//  ToolbarViewModifiers.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/14/22.
//

import SwiftUI

extension Text {
    static func decorate(_ str: String,
                         with intents: InlinePresentationIntent) -> Text {
        var attrString = AttributedString(str)
        attrString.inlinePresentationIntent = intents
        return Text(attrString)
    }
}

struct ReversionAlert: ViewModifier {
    @AppStorage(AppStorageKeys.subjectID.rawValue)
    var subjectID: String = SubjectID.unSet
    @AppStorage(AppStorageKeys.collectedDASI.rawValue)
    var collectedDASI: Bool = false
    @AppStorage(AppStorageKeys.collectedUsability.rawValue)
    var collectedUsability: Bool = false

    @Binding var shouldShow: Bool
    @Binding var nextTask: Int?
    init(next: Binding<Int?>, show: Binding<Bool>) {
        _nextTask = next
        _shouldShow = show
    }

    func body(content: Content) -> some View {
        content
            .alert("Starting Over", isPresented: $shouldShow) {
                Button("Clear All" , role: .destructive) {
                    // Forget user and progress
                    subjectID = SubjectID.unSet
                    Destroy.subject.post()
//                    AppStorageKeys.resetSubjectData()
                    /*
                    collectedDASI = false
                    collectedUsability = false
                    nextTask = .onboarding
                     */
                }
                Button("Keep Subject") {
                    Destroy.dataForSubject.post()

                    nextTask = OnboardContainerView.OnboardTasks.laterGreeting.rawValue
                }
            }
        message: {
            Text("Do you want a new subject, or the same subject with data cleared?\nYou cannot undo this.")
        }
    }
}

struct ReversionToolbar: ViewModifier {
    @Binding var shouldShow: Bool

    init(_ show: Binding<Bool>) {
        _shouldShow = show
    }
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button()
                    {
                        shouldShow = true
                    }
                label: {
                    Label("configure", systemImage: "gear")
                }
                }
            }
            .navigationBarBackButtonHidden(true)
    }
}

extension View {
    func reversionToolbar(_ show: Binding<Bool>) -> some View {
        modifier(ReversionToolbar(show))
    }

    func reversionAlert(next: Binding<Int?>, shouldShow: Binding<Bool>) -> some View {
        modifier(ReversionAlert(next: next, show: shouldShow))
    }
}

