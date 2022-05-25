//
//  CDExtensions.swift
//  KillMeCSV
//
//  Created by Fritz Anderson on 4/8/20.
//  Copyright © 2020 The University of Chicago. All rights reserved.
//

import Foundation
import CoreData

extension NSEntityDescription {
    /// Whether a named relationship for this entity is to-many rather than to-one
    ///
    /// This is important because the predicates for whether the relationship has been nullified are different (`relationship == nil` versus `relationahip.@count == 0`)
    /// - precondition: `name` must not seek a nonexistent relationship.
    /// - Parameter name: The name of the relationship
    /// - Returns: `true` iff the relationship is to-many
    func relationshipIsToMany(_ name: String) -> Bool
    {
        guard let relationship = self.relationshipsByName[name] else {
            fatalError(#function + " - No such relationship named “\(name)” in \(name)")
        }
        return relationship.isToMany
    }
}

struct CDEvents: OptionSet {
    let rawValue: Int
    init(rawValue: Int) { self.rawValue = rawValue }

    static let insert =  CDEvents(rawValue: 1)
    static let update =  CDEvents(rawValue: 2)
    static let delete =  CDEvents(rawValue: 4)

    enum Errors: String, Error {
        case inserting = "Invalid before insertion",
             updating  = "Invalid before updating",
             deleting  = "Invalid before deleting"
    }
}

extension NSManagedObject {

    enum CDXErrors: String, Error {
        case queryFailed
        case deletionFailedNoStore
    }

    func validate(for event: CDEvents) throws {
        if event.contains(.insert) { try self.validateForInsert()   }
        if event.contains(.update) { try self.validateForUpdate()   }
        if event.contains(.delete) { try self.validateForDelete()   }
    }

    /// The instances of an entity that have no reference through any of the named relationships.
    ///
    /// In other words, the other end has nullified the link: If it's to-one the relationship `== nil`; if it's to-many,  `@count == 0` . The instance is an "orphan" if none of the named relationships has any of the named  referents.
    ///
    /// This is useful for collecting instances that can safely be deleted.
    ///
    /// - todo: Why can't this be done by deletion rules?
    /// - Parameters:
    ///   - relationships: The names of the relationships to test.
    ///   - entityName: The name of the entity to search
    ///   - moc: The managed-object context in which to conduct the search.
    /// - Returns: An array of the orphans of the given entity type. Callers may have to conditionally cast the result `as? [DesiredType]`.
    @objc
    public static func orphans(from relationships: [String],
                        ofEntityNamed entityName: String,
                        within moc:  NSManagedObjectContext = CDGlobals.viewContext) -> [NSManagedObject] {
        // If there are no relationships, trivially empty
        guard !relationships.isEmpty else { return [] }
        // The entity has to exist in the moc.
        guard let entity = NSEntityDescription.entity(
            forEntityName: entityName, in: moc) else {
                fatalError(#function + " - No such entity named “\(entityName)”")
        }
        
        // Accumulate predicates per relationship name…
        var predicateList: [NSPredicate] = []
        for r in relationships {
            let queryFormat: String =
                entity.relationshipIsToMany(r) ?
                    "%K.@count == 0" : "%K == nil"
            predicateList.append(NSPredicate(format: queryFormat, r))
        }
        // … and match for all of them being empty.
        let predicates = NSCompoundPredicate(andPredicateWithSubpredicates: predicateList)
        
        // The array of predicates yields the array of orphans.
        let fetch = NSFetchRequest<NSManagedObject>(entityName: entityName)
        fetch.predicate = predicates
        do {
            return try moc.fetch(fetch)
        }
        catch {
            fatalError(#function + " - Failure to fetch orphaned instances of “\(entityName)”: \(error.localizedDescription)")
        }
    }

    /// All instances of an entity.
    ///
    /// The entity is identified by the generic parameter, which is resolved by the type of the variable assigned-to, or by cast.
    /// - note: This is a static function of `NSManagedObject`. `self` refers to that class and gives access to `Self`'s `entity()` function.
    /// - Parameter moc: The managed-object context to draw from, default the `viewMOC`.
    /// - Returns: All members of the entity.
    /// - precondition: The class's entity name should not be `nil`;  the fetch request, if it fails, calls `fatalError()` rather than rethrowing.
    public static func all<T: NSFetchRequestResult>(
        in moc: NSManagedObjectContext = CDGlobals.viewContext) -> [T] {
        guard let entityName = self.entity().name else { fatalError() }
        do {
            let fetch: NSFetchRequest<T> = NSFetchRequest(entityName: entityName)
            return try moc.fetch(fetch)
        }
        catch {
            let message = "\(#function) - malformed fetch of all \(entityName)s:\n\(error.localizedDescription)"
            fatalError(message)
        }
    }
    
    /// Iterate all instances of this managed object class from the store.
    /// - note: If the fetch fails, this is a logical error (or the store is corrupt).
    ///         either way, it's a fatal error.
    /// - Parameters:
    ///   - moc:  The `NSManagedObjectContext` to receive the deletion;
    ///           defaults to the view context for the global persistent container.
    ///   - body: A closure that receives each instance.
    ///   - managedObject: The current managed object in the iteration.
    public static func forEach(
        in moc: NSManagedObjectContext = CDGlobals.viewContext,
        body: (_ managedObject: NSManagedObject)->Void) {
        guard let entityName = self.entity().name else { fatalError() }
        do {
            let fetch: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: entityName)
            let listing = try moc.fetch(fetch)
            for item in listing {
                // relies on segmentBySegmentID
                // being non-nil.
                body(item)
            }
        }
        catch {
            let message = "\(#function) - malformed fetch of all \(entityName)s:\n\(error.localizedDescription)"
            fatalError(message)
        }
    }

    /// Destroy the persistent store serving a managed-object context at a particular location.
    ///
    /// None of the parameters are defaulted; client code must be explicit before destroying data.
    /// - Parameters:
    ///   - url: The location of the store to delete.
    ///   - moc: A managed-object context that owns the store.
    ///   - forcing: Iff `true`, the store will be deleted without regard for consistency and data preservation.
    ///   - throws: `CDXErrors.deletionFailedNoStore` if `moc` is not associated with an NSPersistentStoreCoordinator. Core Data errors thrown by `destroyPersistentStore(at:type:options:)`
    public static func destroy(url: URL,
                        from moc: NSManagedObjectContext,
                        forcing: Bool) throws {
        guard let coordinator = moc.persistentStoreCoordinator else {
            throw CDXErrors.deletionFailedNoStore
        }

        let destroyingOptions: [AnyHashable:Any]? =
        forcing ?
            [NSPersistentStoreForceDestroyOption: true] : nil
        try coordinator.destroyPersistentStore(
            at: url, type: .sqlite,
            options: destroyingOptions)
    }
    
    /// Rempve all members of this `NSManagedObject` class from the store.
    ///
    /// - Parameter moc: The `NSManagedObjectContext` to receive the deletion;
    ///                  defaults to the view context for the global persistent container.
    /// - Throws: Core Data-related errors related to `.execute(_:)` on the MOC.
    public static func purge(from moc: NSManagedObjectContext = CDGlobals.viewContext) throws {
        guard let entityName = self.entity().name else { fatalError() }
        let fetch = NSFetchRequest<NSFetchRequestResult>(
            entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
        var reportableError: Error? = nil
        moc.performAndWait {
            do {
                moc.mergePolicy = NSOverwriteMergePolicy
                //       NSMergeByPropertyObjectTrumpMergePolicy
                try moc.execute(deleteRequest)
                try moc.save()
                try moc.parent?.save()
            }
            catch {
                reportableError = error

                print(#function, "- executing/saving deletion of", entityName, "- error =", error)
                print()
            }
        }
        if let reportableError = reportableError {
            throw reportableError
        }
    }

    /// Thw number of `NSManagedObjects` that are instances of this managed object's entity.
    /// - Parameter moc:     ///  The managed-object context to draw from, default the `viewMOC`.
    /// - Returns: The number of instances of `self`'s entity.
    /// - precondition: If `Self`'s entity has no name, it is a fatal error.
    public static func count(in moc: NSManagedObjectContext = CDGlobals.viewContext) -> Int {
        guard let entityName = self.entity().name else { fatalError() }
        let fetch: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: entityName)
        var retval = 0
        moc.performAndWait {
            do { retval = try moc.count(for: fetch) }
            catch { print(#function, "CD error on trying to count.", error) }
        }
        return retval
    }

    /// Sample a few instances of `self`'sentity.
    ///
    /// The intended use is to show the contents of a few instances of the entity for `print()` debugging.
    /// - Parameters:
    ///   - limit: The maximum number if instances to report. Core Data will return the minimum of `limit` and the existing  number of instances.
    ///   - moc:  The managed-object context to draw from, default the `viewMOC`.
    /// - Returns: Up to `limit` instances of `self`'s entity.
    /// - precondition: The fetch should be well-formed. It is a fatal error for the context to fail with an error,
    public static func fetch<T: NSFetchRequestResult>(
        upTo limit: Int,
        from moc: NSManagedObjectContext = CDGlobals.viewContext) -> [T] {
        let entity = Self.entity()
        
        let fetch: NSFetchRequest<T> = NSFetchRequest(entityName: entity.name!)
        fetch.fetchLimit = limit
        do {
            let result = try moc.fetch(fetch)
            return result
        }
        catch {
            // Throwing from fetch(_:) is a logic error.
            fatalError(#function + " - Can't fetch \(limit) instance of  \(type(of: self))")
        }
    }

    /// Resolve a fetch request defined in the data model.
    /// - Parameters:
    ///   - template: The name of the model-defined template for the predicate
    ///   - params: The parameters for the predicate; see the model definition for the parameter names and types
    ///   - moc:  The managed-object context to draw from, default the `viewMOC`.
    /// - Returns: An array of elements of `self`'s entity; empty if none satisfy the criteria.
    /// - precondition: The named template should be in the model. The resulting fetch must be well-formed. Either is fatal.
    public static func fetchAllWith<T: NSFetchRequestResult>(
        template: String,
        params: [String:AnyObject],
        in moc: NSManagedObjectContext = CDGlobals.viewContext) -> [T]
    {
        guard let fetch = CDGlobals.model
            .fetchRequestFromTemplate(
                withName: template,
                substitutionVariables: params)
            as? NSFetchRequest<T> else {
                fatalError(#function + " - Can't find a template named “\(template)”\n\t \(params)")
        }
        
        do {
            let fetched = try moc.fetch(fetch)
            return fetched
        }
        catch {
            // Throwing from fetch(_:) is a logic error.
            fatalError(#function + " - Can't fetch \(type(of: self)) via Template “\(template)”\n\t \(params)")
        }
    }

    /// Fetch any single instantiation of an entity that satisfies a named predicate and its parameters.
    ///
    /// It is not guaranteed that at most one instance is in the store. It is not guaranteed that the return value will be stable across subsequent calls.
    /// - Parameters:
    ///   - template: The name of a predicate for this managed object subclass.
    ///   - params: The parameters for the predicate; see the model definition for the parameter names and types
    ///   - moc:  The managed-object context to draw from, default is the `Shared.viewContext`.
    /// - Returns: The resulting instance of `Self`, or `nil` if no instance exists.
    public static func fetchOne<T: NSFetchRequestResult>(
        withTemplate template: String,
        params: [String:AnyObject],
        in moc: NSManagedObjectContext = CDGlobals.viewContext) -> T?
    {
        guard let fetch = CDGlobals.model
            .fetchRequestFromTemplate(
                withName: template,
                substitutionVariables: params)
            as? NSFetchRequest<T> else {
                fatalError(#function + " - Can't find a template named “\(template)”\n\t \(params)")
        }
        fetch.fetchLimit = 1
        
        // Look for managed objects answering the template.
        // If none, returns nil.
        do {
            return try moc.fetch(fetch).first
        }
        catch {
            // Throwing from fetch(_:) is a logic error.
            fatalError(#function + " - Can't fetch \(type(of: self)) via Template “\(template)”\n\t \(params)")
        }
    }

    /// Fetch any single instance of a given entity.
    ///
    /// It is not guaranteed that at most one instance is in the store. It is not guaranteed that the return value will be stable across subsequent calls.
    ///
    /// - Parameter moc: The managed-object context to draw from, default is the `Shared.viewContext`.
    /// - Returns: The resulting instance of `Self`, or `nil` if there is no instance in the context.
    public static func fetchOne<T: NSFetchRequestResult>(
       in moc: NSManagedObjectContext = CDGlobals.viewContext) throws -> T?
    {
        let fetch = Self.fetchRequest()
        fetch.fetchLimit = 1
        return try moc.fetch(fetch).first as? T
    }


    /// A line-by-line summary of the entity and some of its instances.
    ///
    /// These include a top-level name-of-entity and coumt, followed by one line per up to `limit` matching objects. Element strings include values of properties named in `properties`.
    ///
    /// The expected use is for `print()` debugging.
    /// - Parameters:
    ///   - properties: The properties to be displayed in the summary for each instance
    ///   - limit: The maximum number of instances to include
    ///   - moc:  The managed-object context to draw from, default the `viewMOC`.
    /// - Returns: An array of Strings, starting with the name-amd count for the entity, followed by up to `limit` strings describing the values of each property named in `properties`.
    public static func summary(properties: [String] = [],
                        limit: Int = 5,
                        in moc: NSManagedObjectContext = CDGlobals.viewContext) -> [String] {
        var output: [String] = []
        guard let eName = self.entity().name else {
            fatalError()
        }

        let objectCount = count(in: moc)
        output.append("\(eName) [\(objectCount)]")
        let elements: [Self]  = Self.fetch(upTo: objectCount, from: moc)
        let strings = elements
            .map { $0 as NSManagedObject }
            .map {
            managedObect -> String in
                properties
                    .map { ($0, managedObect.value(forKey: $0)) }
                    .map { "\($0.0):\($0.1 ?? "nil")" }
                    .joined(separator: " ")
        }
        output += strings
//        for str in output {
//            output.append(str)
//        }
        return output
    }
    
}
