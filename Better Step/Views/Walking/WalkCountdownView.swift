//
//  WalkCountdownView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/20/22.
//

import SwiftUI

struct WalkCountdownView: View {
    @EnvironmentObject var sequencer: WalkingSequence
    @AppStorage(AppStorageKeys.walkInMinutes.rawValue) var durationInMinutes = 6

    var body: some View {
        GeometryReader { proxy in
            VStack {
                Text("\(durationInMinutes.spelled.capitalized) Minute Walk")
                    .font(.largeTitle)
                Spacer()
                Circle()
                    .stroke(lineWidth: 1.0)
                    .foregroundColor(.black)
                    .frame(width: 0.8*proxy.size.width, height: 0.8*proxy.size.width)
                Spacer()
                Button("Cancel") {
                    sequencer.showCountdown = false
                    // TODO: Also stop the countdown.
                }
            }
        }
    }
}

struct WalkCountdownView_Previews: PreviewProvider {
    static var previews: some View {
        WalkCountdownView()
            .frame(width: 300, height: 800, alignment: .center)
    }
}
