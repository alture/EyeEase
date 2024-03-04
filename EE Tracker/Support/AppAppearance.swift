//
//  AppAppearance.swift
//  EE Tracker
//
//  Created by Alisher Altore on 04.03.2024.
//

import Foundation

enum AppAppearance: Int, CaseIterable, Identifiable, CustomStringConvertible {
    case light = 1
    case dark = 2
    case system = 0
    
    var description: String {
        switch self {
        case .light:
            return "Light Mode"
        case .dark:
            return "Dark Mode"
        case .system:
            return "System"
        }
    }
    
    var id: Self {
        return self
    }
}
