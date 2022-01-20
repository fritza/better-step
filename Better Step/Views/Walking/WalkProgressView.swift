//
//  WalkProgressView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/20/22.
//

import SwiftUI

struct WalkProgressView: View {
    @AppStorage("walkDuration") var durationInMinutes = 6

    var body: some View {

        VStack {
            Text("\(durationInMinutes.spelled.capitalized) Minute Walk")
                .font(.largeTitle)
            Spacer()
            TimerView(
                minutePub: MinutePublisher(
                    after: TimeInterval(60*durationInMinutes)
                ))
                .font(.system(size: 120, weight: .ultraLight)
                )

            Spacer()
            Button("Cancel") {
                print("stopping")
                MotionManager.shared.cancelUpdates()
                // TODO: pop out to the main display
            }
        }
    }
}

struct WalkProgressView_Previews: PreviewProvider {
    static var previews: some View {
        WalkProgressView()
    }
}
