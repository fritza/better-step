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

#if false

#warning("Of what use is Keep Subject?")
/// View modifier that presents an alert taking reset (user/data) commands. Its buttons trigger a kind of rewind/erasure.
///
/// There are three buttons.
/// - **Cancel** dismisses the alert without further effect.
/// - **Keep Subject** removes all data for the `Subject`,
/// - **Clear All** removes the `Subject` itself, deleting the data and restoring first-run behavior.
struct ReversionAlert: ViewModifier {
    @AppStorage(AppStorageKeys.subjectID.rawValue)
    var subjectID: String = SubjectID.unSet
    @AppStorage(AppStorageKeys.collectedDASI.rawValue)
    var collectedDASI: Bool = false
    @AppStorage(AppStorageKeys.collectedUsability.rawValue)
    var collectedUsability: Bool = false

    @Binding var shouldShow: Bool

    // FIXME: Is this really used?
    @Binding var nextTask: Int?

    init(next: Binding<Int?>, show: Binding<Bool>) {
        _nextTask = next
        _shouldShow = show
    }

    func body(content: Content) -> some View {
        content
            .alert("Starting Over", isPresented: ResetStatus.shared.$resetAlertVisible) {
//                .alert("Starting Over", isPresented: $shouldShow) {
//                Button("Clear All" , role: .destructive) {
//                    // Forget user and progress
//                    subjectID = SubjectID.unSet
//                    Destroy.subject.post()
//
//                }
                Button("First Run" , role: .destructive) {
                    Destroy.dataForSubject.post()
                    nextTask = OnboardContainerView.OnboardTasks.laterGreeting.rawValue
                }

                Button("Cancel", role: .cancel) {
                    shouldShow = false
                }
            }
        message: {
            Text("Do you want to revert to the first run and collect subject ID, surveys, and walks?\nYou cannot undo this.")
        }
    }
}

struct ReversionButton: View {
    @Binding var shouldShowAlert: Bool

    init(shouldShow: Binding<Bool>) {
        _shouldShowAlert = shouldShow
    }

    var body: some View {
        Button()
        {
            shouldShowAlert = true
            ResetStatus.shared.resetAlertVisible = true
        }
    label: { Label("configure", systemImage: "gear") }
    }
}
/// A modifier that adds a configuration Gear toolbar button that is bever shown if initialized with `shouldShow`.
///
/// The `shouldShow` binding tracks whether to present a ``ReversionAlert`` . If the binding is `true`, then the alert will appear and make reset buttons available.
struct ReversionToolbar: ViewModifier {
    @Binding var shouldShow: Bool

    init(_ show: Binding<Bool>) {
        _shouldShow = show
    }
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    reversionToolbarButton()
                }
                /*
                 Button()
                 { shouldShow = true }
                label: { Label("configure", systemImage: "gear") }
                }
                */
            }
            .navigationBarBackButtonHidden(true)
    }
}
#endif

func reversionToolbarButton() -> some View {
        Button()
        {
            ResetStatus.shared.resetAlertVisible = true
        }
    label: {
        Label("configure", systemImage: "gear")
    }
}

/*
 I want something that will produce a trailing ToolbarItemGroup with gear button
 followed by an optional Button.


 */
