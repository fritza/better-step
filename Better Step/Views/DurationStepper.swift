//
//  DurationStepper.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/25/21.
//

import SwiftUI


struct DurationStepper: View {
    @AppStorage(AppStorageKeys.walkInMinutes.rawValue)
    var minuteDuration = 6
    @EnvironmentObject var config: Configurations

    var body: some View {
        Stepper("Duration (\(config.durationInMinutes)):",
                value: $minuteDuration,
                in: Configurations.durationRange,
                step: 1
//                ,
//                onEditingChanged: { _ in
//            controlFocus = nil
//        }
        )

    }
}

struct DurationStepper_Previews: PreviewProvider {
    static let config: Configurations = {
        return Configurations(startingEmail: "", duration: 9)
    }()

    static var previews: some View {
        DurationStepper()
            .environmentObject(config)
    }
}
