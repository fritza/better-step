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
    var body: some View {
        Stepper("Duration (\(minuteDuration)):",
                value: $minuteDuration,
                in: AppStorageKeys.dasiWalkRange,
                step: 1
//                ,
//                onEditingChanged: { _ in
//            controlFocus = nil
//        }
        )

    }
}

struct DurationStepper_Previews: PreviewProvider {
    static var previews: some View {
        DurationStepper()
            .environmentObject(DASIReportContents())
    }
}
