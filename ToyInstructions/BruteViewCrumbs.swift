//
//  BruteViewCrumbs.swift
//  ToyInstructions
//
//  Created by Fritz Anderson on 3/8/23.
//

import Foundation
import SwiftUI

// MARK: - CardViewSpecies

/// Each case stands for one of the view types that might be presented to the gallery container.
///
/// The associated values are the configuration parameters for those cases.
enum CardViewSpecies {
    // MARK: View types
    case volume(VolumeSpec)
    case instruction(InstructionPageSpec)
    
    // MARK: Construction
    /// Create a `.volume` that carries the provided configuration
    static func newVolume(spec: VolumeSpec) -> Self {
        Self.volume(spec)
    }
    
    /// Create an `.instruction` that carries the provided configuration
    static func newInstruction(spec: InstructionPageSpec) -> Self {
        Self.instruction(spec)
    }
    
    // MARK: View
    /// The `View` that displays a particular case.
    /// - parameter backButtonClosure: The closure to be called when the user taps the "Next" button.
    /// - returns: The `View` created from `self`'s associated value.
    @ViewBuilder
    func makeView(backButtonClosure: @escaping () -> Void) -> some View {
        switch self {
        case .instruction(let spec):
            CardView(pageParams: spec,
                     buttonAction: backButtonClosure)!
            
        case .volume(let spec):
            VolumeAsCardView(pageSpec: spec,
                             buttonAction: backButtonClosure)
        }
    }
}

extension CardViewSpecies: Identifiable, Hashable {
    // MARK: Identifiable
    var id: UUID {
        switch self {
        case .volume(let spec):
            return spec.id
        case .instruction(let spec):
            return spec.id
        }
    }
    
    // MARK: Hashable
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.volume, .instruction), (.instruction, .volume):
            return false
            
        case (.volume(let l), .volume(let r)):
            return l == r
            
        case (.instruction(let l), .instruction(let r)):
            return l == r
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .volume(let spec): hasher.combine(spec)
        case .instruction(let spec): hasher.combine(spec)
        }
    }
}


