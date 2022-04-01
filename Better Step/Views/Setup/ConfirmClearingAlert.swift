//
//  ConfirmClearingAlert.swift
//  Better Step
//
//  Created by Fritz Anderson on 4/1/22.
//

import SwiftUI

struct ThingToClear: Identifiable, Comparable {
    let title: String
    let enabled: Bool
    let id: Int

    init(nameAbleID: (String, Bool, Int)) {
        title = nameAbleID.0
        enabled = nameAbleID.1
        id = nameAbleID.2
    }

    static func == (lhs: ThingToClear, rhs: ThingToClear) -> Bool {
        rhs.id == lhs.id
    }

    static func < (lhs: ThingToClear, rhs: ThingToClear) -> Bool {
        rhs.id > lhs.id
    }
}

struct ConfirmClearingAlert: View {
    @Binding var shouldShow: Bool
    let thing: ThingToClear

    var body: some View {
        Button(action: { shouldShow = true },
               label : { Text(thing.title) }
        )
        .disabled(!thing.enabled)
        .alert(thing.title + "?",
               isPresented: $shouldShow,
               actions: {
            Button("Yes.") {
                shouldShow = false
            }
        })
    }
}

struct ConfirmClearingAlert_Previews: PreviewProvider {
    final class PreviewToClear: ObservableObject {
        @State var shouldShow = true
    }

    static let ptc = PreviewToClear()
    static var previews: some View {
        ConfirmClearingAlert(shouldShow: ptc.$shouldShow,
                       thing: thingsToClear[0])
    }
}
