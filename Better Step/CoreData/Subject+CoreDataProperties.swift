//
//  Subject+CoreDataProperties.swift
//  mommk
//
//  Created by Fritz Anderson on 4/19/22.
//
//

import Foundation
import CoreData


extension Subject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Subject> {
        return NSFetchRequest<Subject>(entityName: "Subject")
    }

    @NSManaged public var subjectID: String?
    @NSManaged public var accSessions: AccSession?
    @NSManaged public var dasiResponses: NSSet?
}

// MARK: Generated accessors for dasiResponses
extension Subject {

    @objc(addDasiResponsesObject:)
    @NSManaged public func addToDasiResponses(_ value: DASIResponse)

    @objc(removeDasiResponsesObject:)
    @NSManaged public func removeFromDasiResponses(_ value: DASIResponse)

    @objc(addDasiResponses:)
    @NSManaged public func addToDasiResponses(_ values: NSSet)

    @objc(removeDasiResponses:)
    @NSManaged public func removeFromDasiResponses(_ values: NSSet)

}

extension Subject : Identifiable {

}
