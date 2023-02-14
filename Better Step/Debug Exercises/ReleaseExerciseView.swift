//
//  ReleaseExerciseView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/13/23.
//

import SwiftUI

struct ReleaseExerciseView: View {
    enum SaveResult {
        case idle, inWork, success(Int), failed
    }
    
    @State var isUnderWay: Bool
    @State var showActivitySheet: Bool
    @State var archiveProgress: SaveResult
    
    init() {
        isUnderWay = false
        showActivitySheet = false
        archiveProgress = .idle
    }
    
    var body: some View {
        VStack (spacing: 24) {
            Text("Test for uploading")
            Button("Proceed") {
                let inFiles = InputFile.loadData(from: jsonTaggedNames)
                InputFile.present(files: inFiles)
                
                isUnderWay = true
//                try! PhaseStorage.shared.createArchive()
                showActivitySheet = true
                // Trigger the uploads
            }
            switch archiveProgress {
            case .idle: Text("Waiting")
            case .failed: Text("Failed").foregroundColor(.red)
            case .success(let count):
                Text("Wrote \(count) bytes")
            case .inWork:
                Text("In process…")
            }
        }
        // Ignore error; this file is
        // not in any build order.
        .onReceive(PhaseStorage.shared.$archiveHasBeenWritten) {
            newValue in
            if newValue {
                archiveProgress = .success(PhaseStorage.shared.count)
                showActivitySheet = true
            }
            else {
                archiveProgress = .idle
            }
        }
        .sheet(isPresented: $showActivitySheet,
               onDismiss: {
            archiveProgress = .idle
        }, content: {
            ActivityUIController(url: PhaseStorage.shared.zipOutputURL)
                .presentationDetents([.medium])
        })
    }
}

struct ReleaseExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        ReleaseExerciseView()
    }
}
