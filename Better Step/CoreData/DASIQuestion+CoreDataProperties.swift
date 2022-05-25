//
//  DASIQuestion+CoreDataProperties.swift
//  mommk
//
//  Created by Fritz Anderson on 4/19/22.
//
//

import Foundation
import CoreData


extension DASIQuestion {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DASIQuestion> {
        return NSFetchRequest<DASIQuestion>(entityName: "DASIQuestion")
    }

    @NSManaged public var number: Int32
    @NSManaged public var score: Double
    @NSManaged public var text: String?

}

extension DASIQuestion : Identifiable {

}
