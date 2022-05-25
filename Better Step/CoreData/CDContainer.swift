//
//  CDContainer.swift
//  Better Step
//
//  Created by Fritz Anderson on 5/25/22.
//

import Foundation
import CoreData

/*
 Agenda:
 Identify the object model
 Open/create an NSPersistentContainer

 This is easier than in mommk, because there's only one possible container, only one possible object model.
 There's no need to make them out of command-line parameters.
 */


public struct CDGlobals {
    // “A public type defaults to having internal members, not public members.”

    static public let containerBaseName = "BetterStep"
    static public let persistentContainer = NSPersistentContainer(name: containerBaseName)

    static public var viewContext: NSManagedObjectContext { persistentContainer.viewContext        }
    static public var model      : NSManagedObjectModel   { persistentContainer.managedObjectModel }

    static public func initialize() {
        // Initialize DASI
        do {
            guard
                let url = Bundle.main.url(forResource: "DASIQuestions",
                                          withExtension: "json")
            else { preconditionFailure() }
            try DASIQuestion.load(from: url,
                                  into: CDGlobals.viewContext)
        }
        catch {
            preconditionFailure("\(#function) - can’t read DASIQuestions.json: \(error)")
        }
    }
}
