//
//  Sphere.swift
//  EE Tracker
//
//  Created by Alisher Altore on 22.02.2024.
//

import Foundation
import SwiftData

@Model
final class Sphere {
    var left: Float = 0.0
    var right: Float = 0.0
    
    var isSame: Bool { left == right }
    var proportional: Bool = false
    var lensItem: LensItem?
    
    init(left: Float = 0, right: Float = 0, proportional: Bool = true, lensItem: LensItem? = nil) {
        self.left = left
        self.right = right
        self.proportional = proportional
        self.lensItem = lensItem
    }
}
