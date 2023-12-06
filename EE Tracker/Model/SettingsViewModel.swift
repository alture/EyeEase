//
//  SettingsViewModel.swift
//  EE Tracker
//
//  Created by Alisher on 04.12.2023.
//

import Foundation
import Combine

enum Plan: String, CaseIterable, Identifiable {
    case free = "Free"
    case pro = "Pro"
    
    var id: Self { self }
}

final class SettingsViewModel: ObservableObject {
    @Published var plan: Plan
    @Published var pushNotificationAllowed: Bool
    @Published var reminderDays: Int
    
    
    init(plan: Plan, pushNotificationAllowed: Bool, reminderDays: Int) {
        self.plan = plan
        self.pushNotificationAllowed = pushNotificationAllowed
        self.reminderDays = reminderDays
    }
}
