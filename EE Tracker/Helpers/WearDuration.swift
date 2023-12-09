//
//  WearDuration.swift
//  EE Tracker
//
//  Created by Alisher on 10.12.2023.
//

import Foundation

enum WearDuration: String, Codable, CaseIterable, Identifiable {
    case daily = "Daily"
    case biweekly = "Bi-weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case halfYearly = "Half-yearly"
    case yearly = "Yearly"
    
    var limit: Int {
        switch self {
        case .daily:
            return 1
        case .biweekly:
            return 14
        case .monthly:
            return 30
        case .quarterly:
            return 90
        case .halfYearly:
            return 180
        case .yearly:
            return 360
        }
    }
    
    var id: Self { self }
}
