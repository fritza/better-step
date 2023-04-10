//
//  BackToolbarView.swift
//  Gallery
//
//  Created by Fritz Anderson on 3/15/23.
//

import SwiftUI


// FIXME: Allow for a "Done" button.
struct BackToolbarView: View {
    let backCallback: () -> Void
    let title: String
    var disabled: Bool
    init(title: String = "< Back", disabled: Bool, _ callback: @escaping () -> Void) {
        self.disabled = disabled
        self.backCallback = callback
        self.title = title
    }
    var body: some View {
        VStack {
            HStack {
                Button(title) {
                    backCallback()
                }
                .disabled(disabled)
                .font(.headline)
                Spacer()
            }
            Divider()
        }
        .toolbar(.hidden, for: .navigationBar)
        .padding()
    }
}

struct BackToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VStack {
                BackToolbarView(disabled: true) {
                    print("Get back")
                }
                Button("< Back") { }
                Spacer()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        // I don' tknow why .hidden doesn't work in previews.
    }
}
