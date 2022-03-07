//
//  DASICardView.swift
//  CardSeries
//
//  Created by Fritz Anderson on 3/4/22.
//

import SwiftUI

struct DASICardView: View {
    @EnvironmentObject var envt: DASIContentState

    var body: some View {
        VStack {
            Spacer()
            Text("Selection: \(envt.selected?.rawValue ?? "OOPS, shouldn't be nil")")
                .font(.largeTitle)
                .padding()
            Button("-> Next") {
                envt.selected = envt.selected?.next
            }
            Spacer()
        }
    }
}

struct DASICardView_Previews: PreviewProvider {
    static var previews: some View {
        DASICardView()
            .environmentObject(DASIContentState(.questions))
    }
}
