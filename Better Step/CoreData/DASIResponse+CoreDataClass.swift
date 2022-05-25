//
//  DASIResponse+CoreDataClass.swift
//  mommk
//
//  Created by Fritz Anderson on 4/11/22.
//
//

import Foundation
import CoreData

#warning("Fetched relationships must be renewed")
/*
 You use refreshObject:mergeChanges: to manually refresh the properties—this causes the fetch request associated with this property to be executed again when the object fault is next fired.


 JUST USE THE FETCH TEMPLATES (.dasiQuestion)
 */

/// The `yes`/`no`/`unknown` response to a question.
///
/// It's expected that new `DASIResponse`s are `.unknown` by default.
public enum ResponseLiteral: String, CustomStringConvertible,
                        ExpressibleByBooleanLiteral {
    case yes, no, unknown

    /// Single-character representation of the selection.
    ///
    ///  `ResponseLiteral.init?(external:)` is supposed to the the inverse.
    public var description: String {
        switch self {
        case .no        : return "N"
        case .unknown   : return "?"
        case .yes       : return "Y"
        }
    }

    /// Create a `ResponseLiteral` from a single-character description.
    ///
    /// The initializer fails if `str` is not among the single-character descriptions.
    /// - Parameter str: The single-character value, as would be returned by `.description`. Case-sensitive.
    public init?(external str: String) {
        switch str {
        case "N"        : self = .no
        case "?"        : self = .unknown
        case "Y"        : self = .yes

        default         : return nil
        }
    }

    /// Accept a literal `Bool` and map into `[.yes,.no]`.
    ///
    /// **See also** `init(_:Bool) `
    public init(booleanLiteral value: BooleanLiteralType) {
        self = value  ? .yes : .no
    }

    /// Create `.yes` or `.no` from `Bool` values.
    /// - Parameter bool: `Bool`, to be mapped to `[.yes,.no]`. `.unknown` is inaccessible.
    public init(_ bool: Bool) {
        self = bool ? .yes : .no
    }
}


/// Managed object representation of a yes/no/unknown response to a `DASIQuestion`.
@objc(DASIResponse)
public class DASIResponse: NSManagedObject {
    var question: DASIQuestion? { // The accessor of the feedbackList property.
        guard let retArray = value(forKey: "questions") as? [DASIQuestion],
              let retval = retArray.first else {
            return nil
        }
        return retval
    }

    /// Create a `DASIResponse` from property values.
    ///
    /// The moc is _not_ saved. There is no check to assure `DASIResponse` is unique by question.
    /// - Parameters:
    ///   - subject: The `Subject` making the response.
    ///   - index: The question ID as provided to `DASIQuestion`.
    ///   - response: `.yes`, `.no`, or `.unknown`
    /// - Returns: The `DASIResponse` as specified.
    static func answer(
        from subject: Subject,
        index: Int32, response: ResponseLiteral) -> DASIResponse {
            let object = NSEntityDescription
                .insertNewObject(forEntityName: "DASIResponse",
                                 into: CDGlobals.viewContext)
            as! DASIResponse
            (object.subject, object.questionNumber, object.answer) =
            (subject, index, response.description)

            // I understand I must call with refresh(_:mergeChanges:) to keep the fetched `question`/`answers` properties current.
            // TODO: Do I need the fetched property?
            //       (See `.dasiQuestion`, below)
            return object
        }

    /// The `DASIQuestion` managed object to which `self` is a response.
    /// - note: Supersedes the `question` fetched property.
    var dasiQuestion: DASIQuestion? {
        let retval: DASIQuestion? = DASIQuestion
            .fetchOne(withTemplate: "withQuestionID",
                      params: ["QUESTIONID": questionNumber as NSNumber],
                      in: self.managedObjectContext ?? CDGlobals.viewContext)
        return retval
    }
}
