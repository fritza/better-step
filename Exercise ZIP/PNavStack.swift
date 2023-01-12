//
//  PNavStack.swift
//  Exercise ZIP
//
//  Created by Fritz Anderson on 1/11/23.
//

import SwiftUI

struct PNavStack: View {
    var body: some View {
        NavigationStack {
            ContentView(source: "Nonsense.json")
                .navigationDestination(for: Piffle.self) {
                    piff in
                    PerPiffleView(currentPiffle: piff)
                }
                .navigationDestination(for: [Piffle].self) { piffList in
                    ZIPProgressView(pList: piffList)
                }
        }
        .padding()
    }
}

struct PNavStack_Previews: PreviewProvider {
    static var previews: some View {
        PNavStack()
    }
}
