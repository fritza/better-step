//
//  AppStaging.swift
//  Better Step
//
//  Created by Fritz Anderson on 6/3/22.
//

import Foundation

protocol StageTasking: AnyObject & Hashable {
    associatedtype Stage: AppStaging
    var name: String { get }
    var id: String { get }
    var stage: Stage? { get }
}

extension StageTasking {
    var id: String {
        let prefix = stage?.id ?? "N/A"
        return "\(prefix):\(self.name)"
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return (lhs.id == rhs.id)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

protocol AppStaging: AnyObject & Hashable {
    associatedtype Task: StageTasking
    var name: String { get }
    var id: String { get }

    var currentTask: Task? { get set }

    var nextTask: Task? { get }
    func incrementTask() -> Task?
    var prevTask: Task? { get }
    func decrementTask() -> Task?
}

extension AppStaging {
    public var id: String { name }
}
