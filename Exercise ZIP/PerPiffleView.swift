//
//  SwiftUIView.swift
//  Exercise ZIP
//
//  Created by Fritz Anderson on 1/11/23.
//

import SwiftUI

struct PerPiffleView: View {
    let currentPiffle: Piffle
    
    var body: some View {
        VStack {
            Spacer()
            Text(currentPiffle.name).font(.largeTitle)
            Spacer()
            Text(currentPiffle.content).font(.body).padding()
            Spacer()
        }
    }
}

struct PerPiffleView_Previews: PreviewProvider {
    static var previews: some View {
        PerPiffleView(currentPiffle: Piffle(name: "Some name", content: "some content"))
    }
}
