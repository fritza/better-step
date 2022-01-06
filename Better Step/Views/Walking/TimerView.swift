//
//  TimerView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/6/22.
//

import SwiftUI

struct TimerView: View {
    @StateObject var minutePub: MinutePublisher
    @State var isFinished: Bool = false
    
    let formatter = MinSecFormatter(showMinutes: true)
    
    var body: some View {
        HStack {
            Spacer()
            Text(try! formatter.formatted(
                minutes: minutePub.minutes,
                seconds: minutePub.seconds)
            )
                .font(.system(size: 40, weight:.thin, design: .default))
                .monospacedDigit()
            Spacer()
        }
        .onReceive(minutePub.completedSubject) { _ in
            isFinished = true
        }
        .onAppear {
            minutePub.start()
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(
            minutePub: MinutePublisher(after: 65)
        )
    }
}
