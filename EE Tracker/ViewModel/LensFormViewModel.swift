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
    var initialUseDate: Date = Date.now.startOfDay
    var sphere: Sphere = Sphere()
    var detail: LensDetail = LensDetail()
    var isWearing: Bool = false
    
    @ObservationIgnored
    var changeDate: Date {
        return Calendar.current.date(byAdding: .day, value: wearDuration.limit, to: initialUseDate) ?? Date.now
    }
    
    @ObservationIgnored
    private(set) var status: Status = .new
    
    @ObservationIgnored
    private var notificationManger: NotificationManager = NotificationManager()
    
    // Output
    var isNameValid: Bool {
        return !brandName.isEmpty
    }
    
    enum Status {
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
    }
    
    func createNotification(by item: LensItem?) {
        guard let item else { return }
        
        notificationManger.scheduleNotificationIfNeeded(for: item)
    }
    
    init(lensItem: LensItem?, status: Status) {
        let dateByStartOfDay = Date.now.startOfDay
        self.brandName = lensItem?.name ?? ""
        self.wearDuration = lensItem?.wearDuration ?? .monthly
        self.eyeSide = lensItem?.eyeSide ?? .both
        
        if status == .changeable {
            self.initialUseDate = dateByStartOfDay
        } else {
            self.initialUseDate = lensItem?.startDate ?? dateByStartOfDay
        }
        
        self.sphere = lensItem?.sphere ?? Sphere()
        self.detail = lensItem?.detail ?? LensDetail()
        self.isWearing = lensItem?.isWearing ?? false
        self.status = status
    }
}

