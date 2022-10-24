//
//  MorseHaptic.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/20/22.
//

import Foundation
import CoreHaptics

// MARK: - MorseHaptic.
/// Player for a haptic in a named AHAP file `rawValue`, a `String`, is the base name for the corresponding AHAP pattern file.
///
/// - warning: `MorseHaptic` relies on `throws` everywhere _except_ the initailzer, which `RawRepresentable` insists must be a non-throwing failable.
struct MorseHaptic: RawRepresentable {
    /// `RawRepresentable` adoption
    let rawValue        : String
    /// The haptic pattern derived from the AHAP file
    var chPattern       : CHHapticPattern?
    /// The location of the AHAP file
    let url             : URL
    /// Singleton haptic engine
    static var engine   : CHHapticEngine!

    static let supportsHaptics: Bool = {
        let capabilities = CHHapticEngine.capabilitiesForHardware()
        return capabilities.supportsHaptics // capabilities.supportsAudio
    }()

    // MARK: Initialization
    /// Initialize all properties (except `chPattern)` from the base name..
    init?(rawValue: String) {
        // Bail if the device doesn't support haptics (both kinds)
        let capabilities = CHHapticEngine.capabilitiesForHardware()
        guard capabilities.supportsAudio, capabilities.supportsHaptics else { return nil }

        do {
            // RawRepresentable compliance
            self.rawValue = rawValue

            // URL of the AHAP pattern file
            guard let aURL = Bundle.main.url(forResource: self.rawValue, withExtension: "ahap") else {
                // Convert the nil to an Error.
                // Doesn't matter in this application, but it's good hygeine.
                let userInfo: [String: Any] = [
                    NSLocalizedDescriptionKey :
                        "Could not find the .ahap “\(rawValue)”"
                ]
                throw NSError(domain: "KMHaptics", code: 1,
                              userInfo: userInfo)
            }

            url = aURL
            // Create no more than one engine
            Self.engine = try Self.engine ?? CHHapticEngine()
            try Self.engine.start()
        }
        catch {
#if DEBUG
            print(#function, "must return nil:", error.localizedDescription)
#endif
            return nil
        }
    }

    // MARK: Loading
    /// The `CHHapticPattern` derived from the `rawValue` value of `self`.
    mutating func pattern() throws -> CHHapticPattern {
        if let chPattern { return chPattern }
        if #available(iOS 16.0, *) {
            chPattern = try CHHapticPattern(contentsOf: url)
        } else {
            let retval = try Self.haptic(from: url)
            chPattern = retval
        }
        return chPattern!
    }

    /// Create a haptic pattern from an `.ahap` (JSON) file at a given `URL`.
    ///
    /// Needed as a fallback from `CHHapticPattern(contentsOf:)` on iOS < 16.0
    static func haptic(from url: URL) throws -> CHHapticPattern {
        let data = try Data(contentsOf: url)
        let decode = try JSONSerialization.jsonObject(
            with: data, options: [])
        guard let dictionary = decode as? [CHHapticPattern.Key : Any] else {
            throw FileStorageErrors.cantReadDictionaryAt(url) }
        let retval = try CHHapticPattern(dictionary: dictionary)
        return retval
    }

    // MARK: Play

    /// Play the pattern.
    mutating func play() throws {
        guard Self.supportsHaptics else { return }
        // Remember that the engine will hold on to the
        // player for the duration. There's no need
        // to assign it to a variable.
        let player: CHHapticPatternPlayer =
        try Self.engine
            .makePlayer(with: try pattern())
        try player.start(atTime: CHHapticTimeImmediate)
    }

    // MARK: Prepared haptic patterns
// if !DEBUG
    /// A haptic for Morse `._  ._  ._` as described in `AAA.ahap`.
//    static var aaa = MorseHaptic(rawValue: "AAA")!
    static var aaa = MorseHaptic(rawValue: "AAAbeep")
    /// A haptic for Morse `_.  _.  _.` as described in `NNN.ahap`.
//    static var nnn = MorseHaptic(rawValue: "NNN")!
    static var nnn = MorseHaptic(rawValue: "NNNbeep")
// endif
}
