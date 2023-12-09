//
//  EyeSide.swift
//  EE Tracker
//
//  Created by Alisher on 10.12.2023.
//

import Foundation

enum EyeSide: String, Codable, CaseIterable, Identifiable {
    case left = "Left"
    case right = "Right"
    case paired = "Paired"
    
    var id: Self { self }
}
