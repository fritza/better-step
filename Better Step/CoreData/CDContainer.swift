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

let containerBaseName = "BetterStep"

func setUpContainer() {
    let container = NSPersistentContainer(name: containerBaseName)
}
