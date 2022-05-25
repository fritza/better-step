//
//  Subject+CoreDataClass.swift
//  mommk
//
//  Created by Fritz Anderson on 4/11/22.
//
//

import Foundation
import CoreData

@objc(Subject)
/// A subject or patient in a Step Test deployment, as the root in an aggregation of accelerometer records and DASI responses.
///
/// The object itself holds only an ID string. Casually storing personally-identifiable information triggers US provacy law; consider carefully before adding attributes.
///
/// Deleting a `Subject` is intended to cascade into deletion of subordinate objects (walk sessions, DASI responses).
public class Subject: NSManagedObject {
    // TODO: Decide what to do with an attempt to insert more than one.

    /// Create a `Subject` object with `subjectID == name`
    /// - Parameter name: The `subjectID` for the new object
    /// - Returns: The new `Subject`.
    public static func subject(from name: String) -> Subject {
        let object = NSEntityDescription
            .insertNewObject(forEntityName: "Subject",
                             into: CDGlobals.viewContext)
        as! Subject
        object.subjectID = name
        return object
    }

    /// Discard any current `Subject` and insert a new one.
    /// - Parameter name: The subject ID for the new `Subject`
    /// - Returns: An inserted and initialized `Subject` with name as the ID.
    public static func replaceSubject(with name: String) throws -> Subject {
        try Subject.purge()
        let newSubject = subject(from: name)
        try CDGlobals.viewContext.save()
        return newSubject
    }

    /// Any instance of `Subject`.
    ///
    /// It is not guaranteed that at most one `Subject` is in the store, nor that the return value will be stable across  calls.
    ///
    /// **See Also** `NSManagedObject.fetchOne<T>(in:)` in `CDExtensions.swift`.
    /// - Parameter moc: The managed-object context to draw from, default is the `Shared.viewContext`.
    /// - Returns: Some instance of `Subject`, or `nil` if there is no `Subject` in the context.
    public static func singleton(in moc: NSManagedObjectContext = CDGlobals.viewContext) throws -> Subject? {
        return try Subject.fetchOne(in: moc)
    }
}
