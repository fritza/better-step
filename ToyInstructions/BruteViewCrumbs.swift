//
//  BruteViewCrumbs.swift
//  ToyInstructions
//
//  Created by Fritz Anderson on 3/8/23.
//

import Foundation
import SwiftUI

private var _instructionSpecs: [InstructionPageSpec]! = nil
func setUpInstructionSpecs(jsonArray: String) {
    guard _instructionSpecs == nil else { return }
    _instructionSpecs = try! InstructionPageSpec
        .from(jsonArray: jsonArray)
}



enum CardViews {
    case volume
    case instructions(index0: Int)
    #warning("Should not be the index, should be a particular OnePage.")
    
    // HOW DO WE INITIALIZE THE SPECS ARRAY?
    // SPECIFICALLY, READING THE JSON FILES.
    // ALSO, THERE'S MORE THAN ONE  ROSTER OF
    // CONTENT (each interstitial)
    
    //    THIS DESIGN ISN'T DONE YET.
    
    static var _instructionSpecs: [InstructionPageSpec]! = nil
    static func setUpInstructionSpecs(jsonArray: String) {
        guard _instructionSpecs == nil else { return }
        _instructionSpecs = try! InstructionPageSpec
            .from(jsonArray: jsonArray)
    }
    
    static subscript(zeroIndex: Int) -> InstructionPageSpec {
        // RELYING ON INSTRUCTIONSPECS BEING FILLED
        -_instructionSpecs[zeroIndex]
    }
    
    static let pageSpecs = try! JSONDecoder()
        .decode([InstructionPageSpec].self, from: <#T##Data#>)
    
    @ViewBuilder
    func body(given spec: any GalleryCardSpec) -> some View {
        switch self {
        case .volume:
            try! VolumeAsCardView(
                contents: VolumeSpec.from(
                    baseName: "Volume"))
            
        case .instructions(index0: let page):
            CardView(pageParams: Self.instructionSpecs[page],
                     buttonAction: {
                print("BEEP! from", "\(#fileID):\(#line)")
            }
            )
        }
    }
}


