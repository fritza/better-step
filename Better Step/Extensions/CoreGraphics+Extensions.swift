//
//  CoreGraphics+Extensions.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/24/22.
//

import Foundation
import CoreGraphics


extension CGSize {
    var short: CGFloat {
        [width, height].min()!
    }
    var long: CGFloat {
        [width, height].max()!
    }
}

