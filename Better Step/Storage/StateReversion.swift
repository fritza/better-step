//
//  StateReversion.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/21/22.
//

import Foundation

/*

 StateReversion / MassDiscardable

 Rationale
 
 Previous iterations relied on a very fine-grained family of destroy-this, destroy-that, zip-saving begun/succeeded/cancelled…
 
 For reversion to the unused, state, al; you need is a siren saying everything has to be reset.
 */

public let RevertAllNotice = Notification.Name(rawValue: "RevertAllNotice")


enum Reversion {
    
    static func postReversion() {
        NotificationCenter.default
            .post(name: RevertAllNotice, object: nil)
    }
}

// Is there some protocol I can make to regularize registration and handling of the RevertAllNotice notification?

protocol MassDiscardable {
    var reversionHandler: AnyObject? { get set }
    // Really? No get?
    
    func handleReversion(notice: Notification) async
}

extension MassDiscardable {
    // I REALLY hope there are no dependencies among reversions
    func installDiscardable() -> AnyObject? {
        //        reversionHandler =
        return NotificationCenter.default
            .addObserver(forName: RevertAllNotice,
                         object: nil, queue: nil,
                         using: handleReversion(notice:))
    }
}

