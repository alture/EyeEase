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
    
    var localizedDescription: String {
        switch self {
        case .left:
            String(localized: "Left", comment: "Eye Side: choose left eye")
        case .both:
            String(localized: "Both", comment: "Eye Side: choose both eyes")
        case .right:
            String(localized: "Right", comment: "Eye Side: choose right eye")
        }
    }
    
    var id: Self { self }
}
