//
//  AccSample+CoreDataProperties.swift
//  mommk
//
//  Created by Fritz Anderson on 4/19/22.
//
//

import Foundation
import CoreData


extension AccSample {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AccSample> {
        return NSFetchRequest<AccSample>(entityName: "AccSample")
    }

    @NSManaged public var magnitude: Double
    @NSManaged public var timeSeconds: Double
    @NSManaged public var x: Double
    @NSManaged public var y: Double
    @NSManaged public var z: Double
    @NSManaged public var session: AccSession?

}

extension AccSample : Identifiable {

}
