//
//  TimeSpeaker.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/22/22.
//

import Foundation
import AVFoundation

#if RETAIN_VOICE
/// The reason an utterance stopped: finished, canceled, or error.
@available(*, unavailable, message: "Excising voice support")
enum ReasonStoppedSpeaking {
    case complete
    case canceled
    case error(Error)
}

/// Interface between client code and `AVSpeechSynthesizer`
///
/// This is where the completion callbacks are collected and transmitted to the async continuation as the return value.
@available(*, unavailable, message: "Excising voice support")
final class TimeSpeaker: NSObject {
    /// Singleton speaker
    static let shared = TimeSpeaker()

    // TODO: I'd like to be able to put in the "get-ready" and "can-halt" instructions.

    private let voiceSynthesizer: AVSpeechSynthesizer
    private var speechContinuation: CheckedContinuation<ReasonStoppedSpeaking, Never>!

    override init() {
        voiceSynthesizer = AVSpeechSynthesizer()

        super.init()
        voiceSynthesizer.delegate = self
    }
}

extension TimeSpeaker: AVSpeechSynthesizerDelegate {
    @MainActor
    /// Pronounce a string at a given pitch and speed.
    ///
    /// - returns: `ReasonStoppedSpeaking`, whether the speech finished by completion or cancellation.
    /// - bug: Should check for cancellation.
    func say(_ string: String, with voice: Voice) async -> ReasonStoppedSpeaking {
        await withCheckedContinuation { (continuation: CheckedContinuation<ReasonStoppedSpeaking,Never>) -> Void in
            guard !Task.isCancelled else { continuation.resume(returning: .canceled); return }
            self.speechContinuation = continuation
            self.voiceSynthesizer.speak(utterance(with: voice, saying: string))

            // As I understand it, then, the return value comes from the
            // continuation calls in the delegate callbacks.
        }
    }

    /// Create a synthesizer "utterance," or text tagged with voice, rate and pitch.
    /// - Parameters:
    ///   - voice: A `Voice` supplying the parameters for the speech fragment.
    ///   - str: The text to pronounce.
    /// - Returns: An iinitialized `AVSpeechUtterance` for the text and manner.
    private func utterance(with voice: Voice, saying str: String) -> AVSpeechUtterance {
        let retval = AVSpeechUtterance(string: str)
        retval.rate = voice.rate
        retval.pitchMultiplier = voice.pitch
        retval.voice = voice.voice
        return retval
    }

    ///`AVSpeechSynthesizerDelegate` method at start of pronouncing the utterance.
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        // Nothing to do.
    }

    ///`AVSpeechSynthesizerDelegate` method at completion.
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.speechContinuation.resume(returning: .complete)
    }

    ///`AVSpeechSynthesizerDelegate` method at cancellation.
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        self.speechContinuation.resume(returning: .canceled)
    }
}

#endif
