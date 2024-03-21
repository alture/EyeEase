//
//  LensFormViewModel.swift
//  EE Tracker
//
//  Created by Alisher Altore on 21.02.2024.
//

import SwiftUI
import UserNotifications
import Observation

@Observable
final class LensFormViewModel {
    
    // Input
    var brandName: String = ""
    var wearDuration: WearDuration = .monthly
    var eyeSide: EyeSide = .both
    var initialUseDate: Date = Date.now
    var sphere: Sphere? = nil
    var detail: LensDetail = LensDetail()
    var isWearing: Bool = false
    
    var changeDate: Date {
        return Calendar.current.date(byAdding: .day, value: wearDuration.limit, to: initialUseDate) ?? Date.now
    }
    
    @ObservationIgnored
    private(set) var status: Status = .new
    
//    @ObservationIgnored
//    private var notificationManger: NotificationManager = NotificationManager()
    
    // Output
    var isNameValid: Bool {
        return !brandName.isEmpty
    }
    
    enum Status: Identifiable {
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
                return "Change"
            }
        }
        
        var navigationTitle: String {
            switch self {
            case .new:
                return "Create New"
            case .editable:
                return "Edit Current"
            case .changeable:
                return "Change Current"
            }
        }
        
        var id: Self {
            self
        }
    }
    
//    func createNotification(by item: LensItem?) {
//        guard let item else { return }
//        
//        notificationManger.scheduleNotificationIfNeeded(for: item)
//    }
    
    init(lensItem: LensItem, status: Status) {
        let dateByStartOfDay = Date.now.startOfDay
        self.brandName = lensItem.name
        self.wearDuration = lensItem.wearDuration
        self.eyeSide = lensItem.eyeSide
        
        if status == .changeable {
            self.initialUseDate = dateByStartOfDay
        } else {
            self.initialUseDate = lensItem.startDate
        }
        
        self.sphere = lensItem.sphere
        self.detail = lensItem.detail ?? LensDetail()
        
        self.isWearing = lensItem.isWearing
        self.status = status
    }
}

