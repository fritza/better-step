//
//  SubjectIDFormatter.swift
//  Better Step
//
//  Created by Fritz Anderson on 2/28/23.
//

import Foundation

/// A `Formatter` that recognizes strings that can be parsed into valid ``SubjectID``s.
///
/// - If the input can be parsed and rendered in canonical format, returns the canonical rendering.
/// - If the input string can't be reformatted to the canonical `letterNNNN`, returns `nil`
///
/// ```swift
/// if let filtered = subjectFormatter.string(from: fieldContent) {
///     self.completedID = filtered
/// } else {
///     self.completedID = "N/A"
/// }
/// ```
/// **Point of confusion**
///
///  `Formatter`s are usually `<T> ↔︎ String`, but in this case it's one-way between two strings: `String → String?`
/// - todo: Parameterize the regular expression that does the recognizing.
final class SubjectIDFormatter: Formatter {
    static let regex = /([SMTWHFA])-?(\d\d\d\d)/
        .ignoresCase()
    
    /// Render an input `String` as an optional.
    ///
    /// The formatter does only the "forward" transformation, from a `TextField String` to a formatted `String?` (if possible).
    ///
    /// - Parameter obj: The user-input (free-format) string.
    /// - Returns: `String?` for the canonical representation, or `nil` if none could be determined`
    /// - todo: Parameterize `Self.regex` to allow for other canonical formats.
    override func string(for obj: Any?) -> String? {
        
        guard let inString = obj as? String,
              let match = try? Self.regex.wholeMatch(
                in: inString)
        else {
            return nil
        }
        let bothMatches = match.output
        let letterMatch = String(bothMatches.1).uppercased()
        let numberMatch = String(bothMatches.2)
        let altered = letterMatch+numberMatch
        //        return String(submatch).uppercased()
        return altered
    }
}
