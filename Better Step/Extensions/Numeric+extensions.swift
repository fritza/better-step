//
//  Numeric+extensions.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/28/22.
//

import Foundation

extension BinaryFloatingPoint {
    func pinned(to range: ClosedRange<Double>) -> Double {
        let asDbl: Double = Double(self)
        if range.contains(asDbl) { return asDbl }
        if asDbl < range.lowerBound { return range.lowerBound }
        if asDbl > range.upperBound { return range.upperBound }
        fatalError()
    }
}

extension ClosedRange where Bound == Double {
    func pinning<F: BinaryFloatingPoint>(_ value: F) -> Double  {
        return value.pinned(to: self)
    }
}
