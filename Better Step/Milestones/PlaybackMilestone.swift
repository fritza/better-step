//
//  PlaybackMilestone.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/20/22.
//

import Foundation
import AVFoundation

/*
let _separated: NumberFormatter = {
    let retval                   = NumberFormatter()
    retval.usesGroupingSeparator = true
    retval.groupingSize          = 3
    retval.groupingSeparator     = "_"
    return retval
}()

extension BinaryInteger {
    var separated: String {
        _separated.string(from: self as! NSNumber)!
    }
}
*/

/// Player for a named audio file in the main bundle.
/// - note: The volume of an ``AVAudioPlayer``is selectable(`0.0 ... 1.0`), but for now it is hard-coded; making it configuratble would be an Exciting Future Direction.
final class AudioMilestone: NSObject {
    enum Errors: Error {
        /// No file of that name is in `Bundle.main`.
        case noURL(String)
        /// `AVAudioPlayer.prepareToPlay()` failed.
        case avCantPrepare
        /// `AVAudioPlayer.play()` failed.
        case avCantStart
    }

    /// The `URL` pointing to the audio data
    let audioURL: URL
    /// The contents of the audio file
    let soundData: Data

    /// The audio session (currently the `sharedInstance`)
    private var session: AVAudioSession
    /// The player instance
    private let player: AVAudioPlayer

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
    init(_ base: String, `extension`: String) throws {
        let urlAndData = try Self.initializeData(
            at: base, extension: `extension`)
        (self.audioURL, self.soundData) = urlAndData

        let tempPlayer = try AVAudioPlayer(data: urlAndData.1)
        player = tempPlayer
        // tempPlayer.volume = 0.6

        let session = AVAudioSession.sharedInstance()
        self.session = session
        try session.setCategory(.playback,
                                mode: .voicePrompt,
                                options: [.duckOthers, .defaultToSpeaker])

        super.init()

        tempPlayer.delegate = self
        guard player.prepareToPlay() else {
            throw Errors.avCantPrepare
        }
    }

    /// Start playing the data loaded from the audio file.
    /// - throws: `.avCantStart` if ``AVAudioPlayer/play()`` returns `false`.
    func play() throws {
        guard player.play() else { throw Errors.avCantStart }
    }
}

extension AudioMilestone: AVAudioPlayerDelegate {
    /// `AVAudioPlayerDelegate` adoption.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("End of sound.")
    }
}



//: [Next](@next)

