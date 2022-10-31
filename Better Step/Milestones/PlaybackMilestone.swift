//
//  PlaybackMilestone.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/20/22.
//

import Foundation
import AVFoundation

fileprivate enum PlaybackConstants {
    static let baseName     = "Countdowns"
    static let `extension`  = "m4a"
    static let volume       = 0.6
}

/// Player for a named audio file in the main bundle.
/// - note: The volume of an `AVAudioPlayer`is selectable(`0.0 ... 1.0`), but for now it is hard-coded; making it configuratble would be an Exciting Future Direction.
final class AudioMilestone
{
    enum Errors: Error {
        /// No file of that name is in `Bundle.main`.
        case noURL(String)
        /// `AVAudioPlayer.prepareToPlay()` failed.
        case avCantPrepare
        /// `AVAudioPlayer.play()` failed.
        case avCantStart
    }

    static var _shared: AudioMilestone?
    static var shared: AudioMilestone {
        if let retval = _shared { return retval }
        _shared = try! AudioMilestone(
            PlaybackConstants.baseName,
            extension: PlaybackConstants.extension)
        return _shared!
    }

    // MARK: Audio data attrubutes
    /// The `URL` pointing to the audio data
    let audioURL: URL
    /// The contents of the audio file
    let soundData: Data

    // MARK: Audio playback attrubutes
    /// The audio session (currently the `sharedInstance`)
    private var session: AVAudioSession
    /// The player instance
    private let player: AVAudioPlayer?
    private let audioDelegate = AudioPlaybackDelegate()

    /// The URL and contents of a file having a certain name and extension.
    ///
    /// Unlike the related `Bundle` instance function, neither parameter is defaulted.
    /// - returns: A pair, `(URL, Data)`, with the URL and content of the file.
    /// - throws: `Errors.noURL` if no such file, `Data` errors if it could not be read.
    private static func initializeData(at name: String, `extension`: String)
    throws -> (URL, Data) {
        guard let nonceURL = Bundle.main.url(
            forResource: name, withExtension: `extension`)
        else {
            throw Errors.noURL("“\(name)”, “. \(`extension`)”")
        }
        let data = try Data(contentsOf: nonceURL)
        return (nonceURL, data)
    }

    /// Construct an instance from the basename and extension of an audio file.
    /// - throws: Errors related to a missing or unreadable file. This object does _not_ validate the content as audio.
    private init(_ base: String, `extension`: String) throws {
        let urlAndData = try Self.initializeData(
            at: base, extension: `extension`)
        (self.audioURL, self.soundData) = urlAndData

        // MARK: Session init
        let session = AVAudioSession.sharedInstance()
        self.session = session
        try session.setCategory(.playAndRecord, mode: .spokenAudio, options: [.duckOthers, .defaultToSpeaker])

        // MARK: Player init
        do {
            let tempPlayer = try AVAudioPlayer(data: soundData)    // Optional player
            tempPlayer.volume = 0.6
            tempPlayer.delegate = audioDelegate
            tempPlayer.prepareToPlay()
            player = tempPlayer

        } catch {
            throw Errors.avCantPrepare
        }
    }

    /// Start playing the data loaded from the audio file.
    /// - throws: ``.avCantStart`` if `AVAudioPlayer/play()` returns `false`.
    func play() throws {
        guard let player else { throw Errors.avCantStart }
        player.currentTime = 0.0
        player.play()
    }

    /// Stop playback.
    ///
    /// > "Calling this method undoes the resource allocation the system performs in `prepareToPlay()` or `play()`"
    func stop() {
        if let player {
            player.stop()
            // NOTE that `AVAudioPlayer/stop()` tears down the
            player.currentTime = 0.0
        }
    }
}

fileprivate final class AudioPlaybackDelegate: NSObject, AVAudioPlayerDelegate {
    // TODO: should the delegate be hidden from clients?
    //       should there be an end-of-audio callback?
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    }
}
