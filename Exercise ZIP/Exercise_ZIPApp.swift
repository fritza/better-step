//
//  Exercise_ZIPApp.swift
//  Exercise ZIP
//
//  Created by Fritz Anderson on 1/10/23.
//

import SwiftUI

@main
struct Exercise_ZIPApp: App {
    @State var currentTag: Int = 0
    var body: some Scene {
        WindowGroup {
            PNavStack()
        }
    }
}

/*
static let piff: Piffle = {
    let retval = try! Piffle.load(from: "Nonsense.json")
    return retval[0]
}()

static var previews: some View {
    PiffleRow(piff)
}
*/

