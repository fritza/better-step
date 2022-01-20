//
//  TimerView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/6/22.
//

import SwiftUI

/// View that displays a time interval in minutes and seconds, supplied by a `MinutePublisher`.
///
/// **See also**
/// * `MinutePublisher`
/// * `MinSecFormatter`
struct TimerView: View {
    @StateObject var minutePub: MinutePublisher
    @State var isFinished: Bool = false
    
    let formatter = MinSecFormatter(showMinutes: true)

    // MARK: Body
    var body: some View {
        HStack {
            Spacer()
            Text(try! formatter.formatted(
                minutes: minutePub.minutes,
                seconds: minutePub.seconds)
            )
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

// MARK: - Preview
struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(
            minutePub: MinutePublisher(after: 65)
        )
    }
}
