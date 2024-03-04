//
//  EyeSide.swift
//  EE Tracker
//
//  Created by Alisher on 10.12.2023.
//

import SwiftUI

enum EyeSide: String, Codable, CaseIterable, Identifiable {
    case left = "Left"
    case both = "Both"
    case right = "Right"
    
    var id: Self { self }
}
