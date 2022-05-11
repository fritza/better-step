//
//  WalkProgressView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/20/22.
//

import SwiftUI

struct WalkProgressView: View {
    @EnvironmentObject var sequencer: WalkingSequence
    @AppStorage(AppStorageKeys.walkInMinutes.rawValue) var durationInMinutes = 6

    var navTitleView: some View {
        Text("\(durationInMinutes.spelled.capitalized) Minute Walk")
            .font(.largeTitle)
    }

    var body: some View {
        VStack {
            navTitleView
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
                sequencer.showProgress = false
            }
            Spacer()
        }
        .padding()
    }
}

struct WalkProgressView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WalkProgressView()
        }
    }
}
