//
//  ComposeExerciseData.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/13/23.
//

import Foundation

let jsonNames = [
    "DASIQuestions",
    "TestXYZT",
    "USurveyQuestions",
    "onboard-intro",
    "usability-intro",
    "second-walk-intro",
    "walk-intro",
    ]

let jsonTaggedNames: [(String, SeriesTag)] =
zip(jsonNames,
    SeriesTag.neededForLaterRuns
)

.map {
    name, phase -> (String, SeriesTag) in
    return (name, phase)
}



struct InputFile {
    typealias StringPhase = (String, SeriesTag)
    
    let baseName: String
    let url     : URL
    let data    : Data
    let phase   : SeriesTag
    
    init(base: String, phase: SeriesTag) {
        // Force phase and subject ID environment.
        // I hope
        if SubjectID.id == SubjectID.unSet {
            SubjectID.id = "sample"
        }
        ASKeys.isFirstRunComplete = true
        
        
        
        let mainBundle = Bundle.main
        guard let jsonURL = mainBundle
            .url(forResource: base,
                 withExtension: "json"),
              let content = try? Data(contentsOf: jsonURL)
        else {
            preconditionFailure()
        }
        
        baseName = base
        url = jsonURL
        data = content
        self.phase = phase
    }
    
    static func loadData(from tagged: [StringPhase]) -> [InputFile] {
        guard !tagged.isEmpty else { return [] }
        let results = tagged
            .map { pair in
                let retval = InputFile(base: pair.0,
                                       phase: pair.1)
                return retval
            }
        return results
    }
    
    // Now present each to PhaseStorage.
    static func present(files: [InputFile]) {
        let storage = PhaseStorage.shared
        for iFile in files {
           try! storage.series(iFile.phase,
                           completedWith: iFile.data)
        }
        
    }
}
