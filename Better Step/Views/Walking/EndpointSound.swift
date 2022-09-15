//
//  EndpointSound.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/8/22.
//

import Foundation
import AVFoundation
import AVFAudio

// MARK: - MP3Errors
enum MP3Errors: Error {
    case noSoundResource(String)
    case noSoundID(String, Int)
}

/// Asynchronously play a sound, then speak some text.
///
/// As implemented, the name of the sound is ignored — it's simply the current beep sound.
/// - note: See Core Haptics for haptic playback (It's iOS API!)
/// - Parameters:
///   - named: The name of the sound to play (NOT USED)
///   - text: The string to be spoken after the sound.
func playSound(named: String, thenSay text: String) {
    Task.detached {
        await SoundPlayer.playSound()
        await CallbackUtterance(string: text).asyncSpeak()
    }
}
// FIXME: Dan will ask about haptics without the beep sound.

// MARK: - SoundPlayer


/// Given the base name of an MP3 file in the main `Bundle`, `SoundPlayer` plays it.
final class SoundPlayer {

    static let klaxonAudioSession: AVAudioSession = {

        var retval: AVAudioSession
        do {
            retval = AVAudioSession()

            // WITH AUDIO BACKGROUND MODE ENABLED
            // Doesn't crash, still observes the ring/silent switch.
//            cat: .playback, mode: .default, opts: []
            // Suspends the app when in the bg, switch silences.
//            cat: .playback, mode: .default, opts: [.mixWithOthers]

            // SEE AVSpeechSynthesizer.usesApplicationAudioSession
            // This may default to a separate session.
            // See what happens if you set it to true.

            let cmo = CatModeOpts(cat: .playback, mode: .default, opts: [.mixWithOthers])
            try cmo.applyTo(session: retval)


        } catch {
            assertionFailure("\(#fileID):\(#line) - Custom session not available:\n\t\(error)")
            retval = AVAudioSession.sharedInstance()
            try! retval.setCategory(.playback,
                                    mode: .voicePrompt,
                                    options: [.duckOthers, .defaultToSpeaker])
        }
        do {
            try retval.setActive(true)
        } catch {
            fatalError("\(#fileID):\(#line) - Can’t actovate session:\n\t\(error)")
        }

        return retval
    }()

    // MARK: Properties
    let soundName: String
    //    private var soundID  : SystemSoundID!

    // MARK: Initialization
    /// Initialize from the base name of the `.mp3` sound file. The file is assumed to be in the main `Bundle`.
    /// - Parameter name: The _base_ name of the audio file.
    /// - throws: AVFoundatin errors from configuring the audio session; or `MP3Error`s if the sound file could not be found or could not be translated into a system sound ID.
    public init(name: String) throws {
        soundName = name
        try Self.initializeAudio()
    }

    // MARK: Use
    /// Play the sound _asynchronously_.
    public static func playSound() async {
        await withCheckedContinuation { continuation in
            // SHOULD have a built-in refactoring, but doesn't.
            AudioServicesPlayAlertSoundWithCompletion(klaxonSoundID) {
                continuation.resume()
            }
        }
    }

    // Should play synchronously, blew it.
//    /// Play the sound _asynchronously._
//    public static func playSoundAndWait() async {
//        await withCheckedContinuation { continuation in
//            // SHOULD have a built-in refactoring, but doesn't.
//            AudioServicesPlayAlertSoundWithCompletion(klaxonSoundID) {
//                continuation.resume()
//            }
//        }
//    }
}

// MARK: Initialization helpers
// FIXME: Can I override volume?
// FIXME: Can I run in the background?
//        Perhaps something similar to telephony?
// FIXME: Can I have sounds override silence?

// (If I were App Review, I'd have some questions to ask)

// AVAudioSession options:
// duckOthers
// defaultToSpeaker

// AVAudioSession modes:
// NOT spokenAudio - it suspends audio to make way for other apps.
// voicePrompt ?
//
// AVAudioSession category:
// playback - "music or other sounds that are **central to the successful use of your app.**"
// NOT ambient (default) - "Your audio is silenced by screen locking and by the Silent switch (called the Ring/Silent switch on iPhone)"

// Klaxon (beep sound)
// It SEEMS to work when the device is asleep
// It DOES NOT override the ring/silent switch.
// It DOES NOT vibrate the device from the background. (the beep is silenced both audio and haptics.

// Not known : Operation in the background.
// Actually, I think it does override device-asleep.
// Success: Speech overrides the Ring/Silent switch.
//          This is a relief because the vibration could he hard to add.
// Short:   Audio clipe seen not to override the switch.

/*
 NEXT: Try a custom audio session.
       Theory: Beep sounds do not run off the shared audio sesson.
 */

extension SoundPlayer {
    static func initializeAudio() throws {
        guard Self.klaxonSoundID == 0 else { return }
        setUpAudioEnvironment()
        try registerKlaxon()
    }

    private static func setUpAudioEnvironment() {
        // TODO: Move the static klaxonAudioSession here.
        //       It's the only caller.
        let _ = Self.klaxonAudioSession
        // MARK: play from background.
        //       Believe solved; see initializer for klaxonAudioSession
    }

    // MARK: initialize the klaxon sound
    private static var klaxonSoundID: SystemSoundID = 0
    private static let klaxonBaseName = "Klaxon"

    private static func registerKlaxon() throws {
        guard Self.klaxonSoundID == 0 else { return }
        // GUARD GUARD GUARD GUARD GUARD GUARD

        guard let soundURL = Bundle.main
            .url(forResource: Self.klaxonBaseName,
                 withExtension: "mp3")
        else {
            throw MP3Errors.noSoundResource(Self.klaxonBaseName)
        }

        let error = AudioServicesCreateSystemSoundID(
            soundURL as CFURL, &Self.klaxonSoundID)
        guard error == noErr else {
            throw MP3Errors.noSoundID(Self.klaxonBaseName,
                                      Int(error))
        }
    }
}

// MARK: CustomStringConvertible
extension SoundPlayer: CustomStringConvertible {
    /// Compliance with `CustomStringConvertible`
    var description: String { "SoundPlayer(\(soundName)" }
}


