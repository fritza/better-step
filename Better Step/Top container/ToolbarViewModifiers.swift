//
//  ToolbarViewModifiers.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/14/22.
//

import SwiftUI
import Combine

let ForceAppReversion = Notification.Name("ForceAppReversion")

// Determine whether to have a top-down ForceAppReversion
// ("App, reset!" -> "Walk, reset", ...)
// or a bottom-up, per-task reversion (static Destroy OptionSet
// ("Walk, reset!" + "DASI, reset!")
// _Is_ there room for both? Destroy has a nifty touch-all-bases
// effect, but maybe not global things like rewinding the
// top phase to onboarding.

extension Text {
    static func decorate(_ str: String,
                         with intents: InlinePresentationIntent) -> Text {
        var attrString = AttributedString(str)
        attrString.inlinePresentationIntent = intents
        return Text(attrString)
    }
}


// TODO: Standardize the name for `shouldShow` in client code.


/// View modifier that binds to a `Bool`. When `true`, an alert appears asking the user whether the app should be reset to virgin state.
///
/// The proceed button (“First Run” ATW) triggers a ``Destroy`` of all data, then broadcasts a `ForceAppReversion` notification.
/// - note: This functionality is _for testing only._ Testers need to start over from scratch; subjects should not.
/// - warning: Probably reversion should be `Destroy`, not the `ForceAppReversion` `Notification`
struct ReversionAlert: ViewModifier {
    @Binding var shouldShow: Bool

    init(_ show: Binding<Bool>) {
        _shouldShow = show
    }

    func body(content: Content) -> some View {
        content
            .alert("Starting Over",
                   isPresented:  $shouldShow
            ) {
                Button("First Run" , role: .destructive) {
                    
                    SubjectID.id = SubjectID.unSet
                    
                    
                    Destroy.all.post()
                    NotificationCenter.default
                        .post(name: ForceAppReversion,
                              object: nil)
                }
                Button("Cancel", role: .cancel) {
                }
            }
    message: {
        Text("Do you want to revert to the first run and collect subject ID, surveys, and walks?\nYou cannot undo this.")
    }   // message/alert
    }   // view
}       // struct

extension View {
    func reversionAlert(on status: Binding<Bool>) -> some View {
        modifier(ReversionAlert(status))
    }
}


struct ReversionButton: View {
    @Binding var toToggle: Bool
    init(toBeSet: Binding<Bool>) {
        _toToggle = toBeSet
    }

    var body: some View {
        Button() {
            toToggle = true
        }
    label: {
        Label("configure", systemImage: "gear")
    }
    }
}
