//
//  MorseHaptic.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/20/22.
//

import Foundation
import CoreHaptics

/// Player for a haptic in a named AHAP file `rawValue`, a `String`, is the base name for the corresponding AHAP pattern file.
///
/// - note: ATW, `MorseHaptic` relies on `.init(contentsOf:)`, which is iOS 16-only.
///                 It should be possible to generate the patterns programmatically, but this gets a beta out the door.
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

    static func haptic(from url: URL) throws -> CHHapticPattern {
        let data = try Data(contentsOf: url)
        let decode = try JSONSerialization.jsonObject(
            with: data, options: [])
        guard let dictionary = decode as? [CHHapticPattern.Key : Any] else {
            throw FileStorageErrors.cantReadDictionaryAt(url) }
        let retval = try CHHapticPattern(dictionary: dictionary)
        return retval
    }

    /*
     /*! @method initWithDictionary:error
      @abstract
      Initialize a new CHHapticPattern using the passed-in NSDictionary.
      @param patternDict
      NSDictionary containing a pattern property list.
      */
     - (nullable instancetype)initWithDictionary:(NSDictionary<CHHapticPatternKey, id> *)patternDict
     error:(NSError **)outError;
     */

    mutating func play() throws {
        // Remember that the engine will hold on to the
        // player for the duration. There's no need
        // to assign it to a variable.
        let player: CHHapticPatternPlayer =
        try Self.engine
            .makePlayer(with: try pattern())
        try player.start(atTime: CHHapticTimeImmediate)
    }

    static var aaa = MorseHaptic(rawValue: "AAA")!
    static var nnn = MorseHaptic(rawValue: "NNN")!
}

