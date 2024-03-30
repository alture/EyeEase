//
//  AppAppearance.swift
//  EE Tracker
//
//  Created by Alisher Altore on 04.03.2024.
//

import Foundation

enum AppAppearance: Int, CaseIterable, Identifiable {
    case light = 1
    case dark = 2
    case system = 0
    
    var localizedDescription: String {
        switch self {
        case .light:
            String(localized: "Light Mode", comment: "App Appearance: Using light mode")
        case .dark:
            String(localized: "Dark Mode", comment: "App Appearance: Using dark mode")
        case .system:
            String(localized: "System", comment: "App Appearance: Using system style")
        }
    }
    
    var id: Self {
        return self
    }
}
