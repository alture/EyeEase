//
//  Sphere.swift
//  EE Tracker
//
//  Created by Alisher Altore on 22.02.2024.
//

import Foundation

struct Sphere: Codable {
    var left: Float
    var right: Float
    
    var isSame: Bool { left == right }
    var proportional: Bool
    
    init(left: Float = 0, right: Float = 0, proportional: Bool = true) {
        self.left = left
        self.right = right
        self.proportional = proportional
    }
}
