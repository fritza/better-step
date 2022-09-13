//
//  CallbackUtterance.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/25/22.
//

import Foundation
import AVFoundation

// MARK: - CallbackUtterance
/// A subclass of `AVSpeechUtterance` that passes a callback for completion of an utterance when the synthesizer hits `didFinish`.
///
/// This represents a _single_ string to be pronounced and should not be re-used.
final class CallbackUtterance: AVSpeechUtterance {

    // MARK: Properties
    ///  Signature for the `CallbackUtterance` callback closure.
    typealias CVUCallback = (CallbackUtterance) -> Void

    static private let speechDelegate = SpeechDelegate()
    static private let synthesizer: AVSpeechSynthesizer = {
        let retval = AVSpeechSynthesizer()
        retval.delegate = speechDelegate
        return retval
    }()

    /// Read-only trampoline for the synthesizer's `isSpeaking`.
    static var isSpeaking: Bool { synthesizer.isSpeaking }
    // true iff speech is in progress or any utterance is in the queue.
    // There's also an isPaused flag, but we don't intend to pause.

    fileprivate let callback: CVUCallback?

    // MARK: Initialization

    /// Initialize a new utterance, corresponding to a single spoken phrase.
    /// - Parameters:
    ///   - string: The `String` whose contents are to be pronounced
    ///   - callback: The `CVUCallback` closure to be called upon completing the phrase. Default `nil`, in which case no completion callback is to be performed.
    init(string: String, callback: CVUCallback? = nil) {
        self.callback = callback
        super.init(string: string)
    }

    /// Required for `NSCoding`. Fatal.
    required init?(coder: NSCoder) {
        fatalError("Does not implement NSCoding")
    }

    /// Initializes a new utterance to pronounce the `minute` and `second` components of  a ``MinSecAndFraction``.
    /// - Parameters:
    ///   - minutesAndSeconds: The minute/second interval to be pronounced.
    ///   - callback: The `CVUCallback` closure to be called upon completing the phrase. Default `nil`, in which case no completion callback is to be performed.
    convenience init(minutesAndSeconds: MinSecAndFraction, callback: CVUCallback? = nil) {
        let speech = minutesAndSeconds.spoken
        self.init(string: speech, callback: callback)
    }

    // MARK: Speech
    /// Present the utterance to the synthesizer for speaking.
    func speak(function: String = #function,
               fileID: String = #file,
               line: Int = #line) {
//                print("CallbackUtterance.speak",
//                      "called from", function, "\(fileID):\(line)")
        Self.synthesizer.speak(self)
    }

    func asyncSpeak(function: String = #function,
                    fileID: String = #file,
                    line: Int = #line) async {
//        print("CallbackUtterance.asyncSpeak",
//              "called from", function, "\(fileID):\(line)")

        self.speak()
        do {
            repeat {
                try await Task.sleep(nanoseconds: 100 * NSEC_PER_MSEC)
            } while Self.synthesizer.isSpeaking
        }
        catch {
            print("Don't care:", error.localizedDescription)
        }
    }

    /// Stop the shared `AVSpeechSynthesizer`. Tha'ts global, so this interrupts all pending `CallbackUtterance`s
    static func stop() {
        Self.synthesizer.stopSpeaking(at: .immediate)
    }
}

// MARK: - SpeechDelegate
final class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
    // REMEMBER! AVSpeechSynthesizer keeps a queue of its own.
    /// `AVSpeechSynthesizerDelegate` adoption for the end of an utterance.
    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance) {
            if let callbackUtterance = utterance as? CallbackUtterance {
                callbackUtterance.callback?(callbackUtterance)
            }
            else {
                preconditionFailure("\(#function) got a strange utterance from callback.")
            }
        }
}

// MARK: - Deprecations
// MARK: CallbackUtterance
extension CallbackUtterance {
    /// Utter a speakable description of a `MinSecondPair`.
    ///
    /// The utterance is stored in a `static` reference until it calls back to say it's done.
    @available(*, deprecated,
                message: "Use CallbackUtterance/init(minutesAndSeconds:callback:) instead.")
    static func sayCountdown(minutesAndSeconds: MinSecAndFraction) {
//        guard shouldSpeak else { return }
        let newUtterance =
        CallbackUtterance(
            minutesAndSeconds: minutesAndSeconds) {
                back in
                print(#function, "Callback for", back.speechString)
            }
        newUtterance.speak()

        // NOTE: All the get/set utterance shouldn't
        //       be necessary: if you send more than
        //       one utterance, it'll be queued.
    }
}
