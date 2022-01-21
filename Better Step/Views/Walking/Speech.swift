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


enum Voice {
    case routine, clipped, instructional

    var rate: Float {
        switch self {
        case .routine: return 0.45
        case .clipped: return 0.50
        case .instructional: return 0.45
        }
    }

    var pitch: Float {
        switch self {
        case .routine: return 1.0
        case .clipped: return 1.02
        case .instructional: return 1.0
        }
    }

    var voice: AVSpeechSynthesisVoice {
        let language = Locale.current.identifier
        // The US voice is guaranteed, so forced unwrap is okay (or fatal)
        return
            AVSpeechSynthesisVoice(language: language) ??
                AVSpeechSynthesisVoice(language: "en-US")!
    }

    func utterance(saying str: String) -> AVSpeechUtterance {
        let retval = AVSpeechUtterance(string: str)
        retval.rate = rate
        retval.pitchMultiplier = pitch
        retval.voice = voice
        return retval
    }

//    func say(_ str: String) {
//        DispatchQueue.main
//            .async {
//                CountdownSpeaker
//                    .voiceSynthesizer
//                    .speak(
//                        self.utterance(saying: str))
//        }
//    }

    typealias SpeechContinuation = CheckedContinuation<Void, Never>
    static var speechContinuation: SpeechContinuation?
    func say(_ str: String) async {
        await withCheckedContinuation { (continuation: SpeechContinuation) in
            Self.speechContinuation = continuation
            CountdownSpeaker.voiceSynthesizer.speak(self.utterance(saying: str))
        }
    }
}

protocol CountdownSpeakerDelegate: AnyObject {
    func countdownSpeakerDidFinishSaying(_ string: String)
    func countdownSpeakerDidStartSaying(_ string: String)
}

enum CountdownSpeaker {
    static var voiceSynthesizer: AVSpeechSynthesizer {
        return _CountdownSpeaker.speechSynthesizer
    }

    static let speakerObject: _CountdownSpeaker = {
        return _CountdownSpeaker()
    }()

    static var delegate: CountdownSpeakerDelegate? {
        get { return speakerObject.delegate }
        set { speakerObject.delegate = newValue }
    }

    static func say(_ string: String, in voice: Voice,
                    delayByMS delay: Int = 0) {
        DispatchQueue.main.async {
            speakerObject.say(string, in: voice, delayByMS: delay)
        }
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
    func say(_ string: String, with voice: Voice) async {
        await withCheckedContinuation { (continuation: CheckedContinuation<ReasonStoppedSpeaking,Never>) -> Void in
            self.speechContinuation = continuation
            self.voiceSynthesizer.speak(utterance(with: voice, saying: string))
        }
    }

    func utterance(with voice: Voice, saying str: String) -> AVSpeechUtterance {
        let retval = AVSpeechUtterance(string: str)
        retval.rate = voice.rate
        retval.pitchMultiplier = voice.pitch
        retval.voice = voice.voice
        return retval
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        // Nothing to return with.
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.speechContinuation?.resume(returning: .complete)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        self.speechContinuation?.resume(returning: .canceled)
    }
}
