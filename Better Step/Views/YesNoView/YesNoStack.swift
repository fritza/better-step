//
//  YesNoStack.swift
//  CardSeries
//
//  Created by Fritz Anderson on 3/4/22.
//

import SwiftUI



struct YesNoStack: View {
    typealias IntVoid = ((Int) -> Void)

    @State var selectedButtonID: Int

    var callback: IntVoid? = nil

    func selectButton(id button: YesNoButton) {
        selectedButtonID = button.id
        callback?(button.id)
    }

    var body: some View {
        VStack {
            YesNoButton(id: 1,
                        title: "Yes".asChecked(selectedButtonID == 1),
                        completion: selectButton(id:)
            )
            Spacer(minLength: 24)
            YesNoButton(id: 2,
                        title: "No".asChecked(selectedButtonID == 2),
                        completion: selectButton(id:))
            Spacer()
        }
        .padding()
    }
}

struct YesNoStack_Previews: PreviewProvider {
    @State static var last: String = "NONE"
    static var previews: some View {
        VStack {
            YesNoStack(selectedButtonID: 7) { index in }
            .frame(height: 160, alignment: .center)
        }
    }
}
