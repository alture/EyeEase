//
//  LensUsage.swift
//  EE Tracker
//
//  Created by Alisher Altore on 08.05.2024.
//

import SwiftData
import Foundation

enum LensType: String, CaseIterable, Identifiable, Codable {
    case biWeekly = "Bi-Weekly"
    case monthly = "Monthly"
    case quarterly = "Quartelry"
    case semiAnnual = "Semi Annual"
    case all = "All"
    
    var id: Self {
        self
    }
}

enum LensStatus: String, CaseIterable, Identifiable, Codable {
    case current = "Current"
    case overdue = "Expired"
    case replaced = "Replaced"
    case all = "All"
    
    var id: Self {
        self
    }
}

struct LensUsage: DateRepresentable, Identifiable {
    let id = UUID()
    var type: LensType
    var status: LensStatus
    var startDate: Date
    var endDate: Date
}
