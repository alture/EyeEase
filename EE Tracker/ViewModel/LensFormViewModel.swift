//
//  LensFormViewModel.swift
//  EE Tracker
//
//  Created by Alisher Altore on 21.02.2024.
//

import SwiftUI
import UserNotifications
import Combine
import Observation

@Observable
final class LensFormViewModel {
    
    // Input
    var brandName: String = ""
    var wearDuration: WearDuration = .monthly
    var eyeSide: EyeSide = .both
    var initialUseDate: Date = Date.now
    var sphere: Sphere = Sphere()
    var detail: LensDetail = LensDetail()
    var isWearing: Bool = true
    private(set) var status: Status = .new
    private(set) var lensItem: LensItem?
    
    // Output
    var isNameValid = true
    
    private var cancellableSet: Set<AnyCancellable> = []
    
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
        let content = UNMutableNotificationContent()
        content.title = "EyeEase"
        content.body = "\(item.name) will expire today"
        content.sound = UNNotificationSound.default
        
        var dateComponent = DateComponents()
        dateComponent.day = item.remainingDays
        dateComponent.hour = 10
        
        print(dateComponent.description)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])
        UNUserNotificationCenter.current().add(request)
    }
    
    init(lensItem: LensItem?, status: Status) {
        self.brandName = lensItem?.name ?? ""
        self.wearDuration = lensItem?.wearDuration ?? .biweekly
        self.eyeSide = lensItem?.eyeSide ?? .both
        
        if status == .changeable {
            self.initialUseDate = Date.now
        } else {
            self.initialUseDate = lensItem?.startDate ?? Date.now
        }
        
        self.sphere = lensItem?.sphere ?? Sphere()
        self.detail = lensItem?.detail ?? LensDetail()
        self.isWearing = lensItem?.isWearing ?? true
        self.status = status
        
//        brandName
//            .publisher
//            .receive(on: RunLoop.main)
//            .collect()
//            .map { name in
//                return name.count > 0
//            }
//            .assign(to: \.isNameValid, on: self)
//            .store(in: &cancellableSet)
    }
}
