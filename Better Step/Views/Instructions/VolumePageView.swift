//
//  VolumePageView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/13/23.
//

import SwiftUI

struct VolumePageView: View, ReportingPhase {
    typealias SuccessValue = Void
    let completion: ClosureType
    
    init(completion: @escaping ClosureType) {
        self.completion = completion
    }
    
    var body: some View {
        VStack {
            VStack {
                Spacer()
                Text("To help you complete your walk, you will hear spoken intructions on when to start, and when your walk is done")
                    .font(.title3)
                Image("loudness")
                    .scaledAndTinted()
                    .frame(width: 360)
                Text("Make sure the mute switch is in the un-mute (up) position, and the volume is all the way high.")
                    .font(.title3)
                Spacer()
                Button("Start") {
                    let returnValue = ResultValue.success(())
                    completion(returnValue)
                }
                .fontWeight(.bold)
            }.font(.body)
        }
        .padding()
        .navigationTitle("Turn up the volume")
    }
}

struct VolumePageView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VolumePageView() { _ in
                print("Next step!")
            }
        }
    }
}
