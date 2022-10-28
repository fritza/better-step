//
//  ToolbarViewModifiers.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/14/22.
//

import SwiftUI
import Combine

let ForceAppReversion = Notification.Name("ForceAppReversion")

extension Text {
    static func decorate(_ str: String,
                         with intents: InlinePresentationIntent) -> Text {
        var attrString = AttributedString(str)
        attrString.inlinePresentationIntent = intents
        return Text(attrString)
    }
}

struct ReversionAlert: ViewModifier {
//    @Binding var resetState: ResetStatus
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
                    Destroy.dataForSubject.post()
                }

                Button("Cancel", role: .cancel) {
                    //                    shouldShow = false
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
