//
//  ReleaseExerciseView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/13/23.
//

import SwiftUI

struct ReleaseExerciseView: View {
    @State var isUnderWay: Bool
    
    var body: some View {
        VStack (spacing: 24) {
            Text("Test for uploading")
            Button("Proceed") {
                isUnderWay = true
                // Trigger the uploads
            }
            Text(isUnderWay ? "in work" : "completed")
        }
        .onChange(of: isUnderWay) { newValue in
            if newValue {
                // isUnderWay is now true.
                let inFiles = InputFile.loadData(from: jsonTaggedNames)
                
                InputFile.present(files: inFiles)
            }
            else {
                // Is under way has changed to false
            }
        }
    }
}

struct ReleaseExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        ReleaseExerciseView()
    }
}
