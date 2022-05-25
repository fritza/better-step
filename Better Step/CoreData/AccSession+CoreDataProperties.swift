//
//  AccSession+CoreDataProperties.swift
//  mommk
//
//  Created by Fritz Anderson on 4/19/22.
//
//

import Foundation
import CoreData


extension AccSession {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AccSession> {
        return NSFetchRequest<AccSession>(entityName: "AccSession")
    }

    @NSManaged public var start: Double
    @NSManaged public var samples: NSOrderedSet?
    @NSManaged public var subject: Subject?

}

// MARK: Generated accessors for samples
extension AccSession {

    @objc(insertObject:inSamplesAtIndex:)
    @NSManaged public func insertIntoSamples(_ value: AccSample, at idx: Int)

    @objc(removeObjectFromSamplesAtIndex:)
    @NSManaged public func removeFromSamples(at idx: Int)

    @objc(insertSamples:atIndexes:)
    @NSManaged public func insertIntoSamples(_ values: [AccSample], at indexes: NSIndexSet)

    @objc(removeSamplesAtIndexes:)
    @NSManaged public func removeFromSamples(at indexes: NSIndexSet)

    @objc(replaceObjectInSamplesAtIndex:withObject:)
    @NSManaged public func replaceSamples(at idx: Int, with value: AccSample)

    @objc(replaceSamplesAtIndexes:withSamples:)
    @NSManaged public func replaceSamples(at indexes: NSIndexSet, with values: [AccSample])

    @objc(addSamplesObject:)
    @NSManaged public func addToSamples(_ value: AccSample)

    @objc(removeSamplesObject:)
    @NSManaged public func removeFromSamples(_ value: AccSample)

    @objc(addSamples:)
    @NSManaged public func addToSamples(_ values: NSOrderedSet)

    @objc(removeSamples:)
    @NSManaged public func removeFromSamples(_ values: NSOrderedSet)

}

extension AccSession : Identifiable {

}
