//
//  WearDuration.swift
//  EE Tracker
//
//  Created by Alisher on 10.12.2023.
//

import SwiftUI

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
    
    var localizedDescriptionFull: String {
        switch self {
        case .daily:
            String(localized: "Daily")
        case .biweekly:
            String(localized: "Bi-weekly (14 days)")
        case .monthly:
            String(localized: "Monthly (30 days)")
        case .quarterly:
            String(localized: "Quarterly (90 days)")
        case .halfYearly:
            String(localized: "Half-yearly (180 days)")
        case .yearly:
            String(localized: "Yearly")
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .daily:
            String(localized: "Daily")
        case .biweekly:
            String(localized: "Bi-weekly")
        case .monthly:
            String(localized: "Monthly")
        case .quarterly:
            String(localized: "Quarterly")
        case .halfYearly:
            String(localized: "Half-yearly")
        case .yearly:
            String(localized: "Yearly")
        }
    }
    
    var id: Self { self }
}
