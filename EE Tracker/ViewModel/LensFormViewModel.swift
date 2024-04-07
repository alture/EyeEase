//
//  LensFormViewModel.swift
//  EE Tracker
//
//  Created by Alisher Altore on 21.02.2024.
//

import SwiftUI
import UserNotifications
import Observation

enum FormState: Identifiable {
    case new
    case editable
    case changeable
    
    var actionTitle: String {
        switch self {
        case .new:
            return "Add"
        case .editable:
            return "Save"
        case .changeable:
            return "Replace"
        }
    }
    
    var navigationTitle: String {
        switch self {
        case .new:
            return "Create New"
        case .editable:
            return "Edit Current"
        case .changeable:
            return "Replace Current"
        }
    }
    
    var id: Self {
        self
    }
}

@Observable
final class LensFormViewModel {
    
    var brandName: String = ""
    var wearDuration: WearDuration = .biweekly
    var eyeSide: EyeSide = .both
    var initialUseDate: Date = Date.now.startOfDay
    var sphere: Sphere? = nil
    var detail: LensDetail = LensDetail()
    var isWearing: Bool = false
    
    @ObservationIgnored
    var changeDate: Date {
        return Calendar.current.date(byAdding: .day, value: wearDuration.limit, to: initialUseDate) ?? Date.now
    }
    
    var isNameValid: Bool {
        return !brandName.isEmpty
    }
    
    func createNotification(by item: LensItem) {
        if let notificationManager = NotificationManager.shared {
            Task {
                await notificationManager.scheduleNotifications(for: item)
            }
        }
    }
    
    func cancelNotification(by id: UUID) {
        if let notificationManager = NotificationManager.shared {
            Task {
                await notificationManager.cancelNotification(for: id)
            }
        }
    }
    
    func updateNotification(by item: LensItem) {
        if let notificationManager = NotificationManager.shared {
            Task {
                await notificationManager.updateNotifications(for: item)
            }
        }
    }
}

