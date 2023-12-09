//
//  SettingsModel.swift
//  EE Tracker
//
//  Created by Alisher on 10.12.2023.
//

import Foundation

enum Plan: String, Codable, CaseIterable, Identifiable {
    case free = "Free"
    case pro = "Pro"
    
    var id: Self { self }
}

final class SettingsModel: ObservableObject {
    var plan: Plan
    var pushNotificationAllowed: Bool
    var reminderDays: Int
    
    init(plan: Plan, pushNotificationAllowed: Bool, reminderDays: Int) {
        self.plan = plan
        self.pushNotificationAllowed = pushNotificationAllowed
        self.reminderDays = reminderDays
    }
}
