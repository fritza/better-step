//
//  Voice.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/21/22.
//

import Foundation
import AVFoundation

#if RETAIN_VOICE
/// rate, pitch, and synthesis of a particular style of speech.
///
/// - `.routine`: Ordinary speech
/// - `.clipped`: Time-specific speech, such as "start walking"
/// - `.instructional`: Narrative of the next task
///
/// - note: At this writing,` .routine `and `.instructional` are the same.
@available(*, unavailable, message: "Excising voice support")
enum Voice {
    case routine, clipped, instructional

    /// The pace at which the utterance is spoken; `clipped` is a bit faster.
    var rate: Float {
        switch self {
        case .routine: return 0.45
        case .clipped: return 0.50
        case .instructional: return 0.45
        }
    }

    /// The pitch of the speech: `clipped` is a bit higher
    var pitch: Float {
        switch self {
        case .routine: return 1.0
        case .clipped: return 1.02
        case .instructional: return 1.0
        }
    }

    /// The speech synthesizer for this voice
    ///
    /// - note: Which voice `self` is has no effect at this writing.
    var voice: AVSpeechSynthesisVoice {
        let language = Locale.current.identifier
        // The US voice is guaranteed, so forced unwrap is okay (or fatal)
        return
            AVSpeechSynthesisVoice(language: language) ??
                AVSpeechSynthesisVoice(language: "en-US")!
    }

    /// Pronounce a `String` in this voice.
    ///
    /// Implemented in terms of `TimeSpeaker.say(_:with:)`
    /// - Parameter str: The text to pronounce
    /// - Returns: The reason (finished or cancelled) the speech stopped.
    func say(_ str: String) async -> ReasonStoppedSpeaking {
        await TimeSpeaker.shared.say(str, with: self)
    }
}

#endif
