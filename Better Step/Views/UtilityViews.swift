//
//  UtilityViews.swift
//  Better Step
//
//  Created by Fritz Anderson on 5/23/22.
//

import SwiftUI

func gearBarItem(action: (() -> Void)? = nil) -> some View {
    Button {
        let realAction = action ?? { print("\(#function) → N/A") }
        realAction()
    }
label: {
    Label("configuration", systemImage: "gear")
}
}
