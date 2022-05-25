//
//  DASIResponse+CoreDataProperties.swift
//  mommk
//
//  Created by Fritz Anderson on 4/26/22.
//
//

import Foundation
import CoreData


extension DASIResponse {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DASIResponse> {
        return NSFetchRequest<DASIResponse>(entityName: "DASIResponse")
    }

    @NSManaged public var answer: String?
    @NSManaged public var questionNumber: Int32
    @NSManaged public var subject: Subject?

}

extension DASIResponse : Identifiable {

}
