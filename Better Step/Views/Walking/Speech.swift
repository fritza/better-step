//
//  Speech.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/21/22.
//

import Foundation
import Combine
import SwiftUI
import AVFoundation

/// rate, pitch, and synthesis of a particular style of speech.
///
/// - `.routine`: Ordinary speech
/// - `.clipped`: Time-specific speech, such as "start walking"
/// - `.instructional`: Narrative of the next task
///
/// - note: At this writing,` .routine `and `.instructional` are the same.
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

    static func stop(now: Bool = false) {
        DispatchQueue.main.async {
            speakerObject.stop(now: now)
        }
    }
}

class _CountdownSpeaker: NSObject, AVSpeechSynthesizerDelegate {
    weak var delegate: CountdownSpeakerDelegate?

    static let voice: AVSpeechSynthesisVoice? = {
        return AVSpeechSynthesisVoice(identifier: "en-US")
    }()
    static let speechSynthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        _CountdownSpeaker.speechSynthesizer.delegate = self
    }

    func say(_ string: String, in voice: Voice,
             delayByMS delay: Int = 0) async {
        if delay == 0 {
            voice.say(string)
            delegate?.countdownSpeakerDidStartSaying(string)
        }
        else {
            let hesitation = DispatchSource.makeTimerSource(
                flags: [], queue: DispatchQueue.main)
            let deadline =  DispatchWallTime.now()
                + DispatchTimeInterval.milliseconds(delay)
            hesitation.schedule(wallDeadline: deadline)
            hesitation.setEventHandler {
                self.say(string, in: voice)
            }
            hesitation.resume()
        }
    }

    func stop(now: Bool) {
        let when: AVSpeechBoundary = now ? .immediate : .word
        _CountdownSpeaker.speechSynthesizer.pauseSpeaking(at: when)
    }


    // MARK: Speech delegate

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        delegate?
            .countdownSpeakerDidFinishSaying(
                utterance.speechString)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        delegate?
            .countdownSpeakerDidStartSaying(utterance.speechString)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
    }
 }

enum ReasonStoppedSpeaking {
    case complete
    case canceled
    case error(Error)
}

/// Interface between client code and `AVSpeechSynthesizer`
///
/// This is where the completion callbacks are collected and transmitted to the async continuation as the return value.
final class TimeSpeaker: NSObject {
    @EnvironmentObject var timer: WrappedTimer
    // I'd like to be able to put in the "get-ready" and "can-halt" instructions.

    let voiceSynthesizer: AVSpeechSynthesizer
    var speechContinuation: CheckedContinuation<ReasonStoppedSpeaking, Never>?

    override init() {
        voiceSynthesizer = AVSpeechSynthesizer()
        voiceSynthesizer.delegate = self
        super.init()
    }
}

extension TimeSpeaker: AVSpeechSynthesizerDelegate {
    /// Pronounce a string at a given pitch and speed.
    ///
    /// - returns: `ReasonStoppedSpeaking`, whether the speech finished by completion or cancellation.
    /// - bug: Should check for cancellation.
    func say(_ string: String, with voice: Voice) async -> ReasonStoppedSpeaking {
        await withCheckedContinuation { (continuation: CheckedContinuation<ReasonStoppedSpeaking,Never>) -> Void in
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
        self.speechContinuation?.resume(returning: .complete)
    }

    ///`AVSpeechSynthesizerDelegate` method at cancellation.
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        self.speechContinuation?.resume(returning: .canceled)
    }
}
