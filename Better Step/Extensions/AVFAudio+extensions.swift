//
//  AVFAudio+extensions.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/25/22.
//

import Foundation
import AVFAudio

extension AVAudioSession.Mode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .`default`:        return ".default"
        case .gameChat :        return ".gameChat"
        case .measurement:      return ".measurement"
        case .moviePlayback:    return ".moviePlayback"
        case .spokenAudio:      return ".spokenAudio"
        case .videoChat:        return ".videoChat"
        case .videoRecording:   return ".videoRecording"
        case .voiceChat:        return ".voiceChat"
        case .voicePrompt:      return ".voicePrompt"
        default:           return "Unknown mode  (\(self.rawValue))"
        }
    }
}

extension AVAudioSession.Category: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ambient:         return ".ambient"
        case .multiRoute:      return ".multiRoute"
        case .playAndRecord:   return ".playAndRecord"
        case .playback:        return ".playback"
        case .record:          return ".record"
        case .soloAmbient:     return ".soloAmbient"
//        case .audioProcessing: return ".audioProcessing"
        default:        return "Unknown category (\(self.rawValue))"
        }
    }
}

/// Encapsulates the `AVAudioSession/.setCategory(_:mode:options:)`  parameters.
struct CatModeOpts: CustomStringConvertible {
    internal init(cat: AVAudioSession.Category,
                  mode: AVAudioSession.Mode = .default,
                  opts: AVAudioSession.CategoryOptions = []) {
        self.cat = cat
        self.mode = mode
        self.opts = opts
    }

    let cat: AVAudioSession.Category
    let mode: AVAudioSession.Mode
    let opts: AVAudioSession.CategoryOptions

    var description: String {
        "CatModeOpts: c: \(cat), m: \(mode), o: \(opts)"
    }

    /// Apply the values
    func applyTo(session: AVAudioSession) throws {
        try  session.setCategory(cat, mode: mode, options: opts)
    }
}
