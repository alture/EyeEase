//
//  NotificationManager.swift
//  EE Tracker
//
//  Created by Alisher Altore on 04.03.2024.
//

import UserNotifications
import Observation
import UIKit
import Combine
import SwiftUI

final class NotificationManager: ObservableObject {
    private(set) var notifications: [UNNotificationRequest] = []
    @Published private(set) var authorizationStatus: UNAuthorizationStatus?
    @AppStorage(AppStorageKeys.reminderDays) var reminderDays: ReminderDays = .three {
        didSet {
            reminderDaysSubject.send()
        }
    }
    
    var reminderDaysPublisher: AnyPublisher<Void, Never> {
        reminderDaysSubject.eraseToAnyPublisher()
    }
    
    private var reminderDaysSubject = PassthroughSubject<Void, Never>()
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] isGranted, error in
            DispatchQueue.main.async {
                if let error {
                    print("Error requesting notification permissions: \(error)")
                    return
                }
                
                self?.reloadAuthorizationSatus()
            }
        }
    }
    
    func reloadAuthorizationSatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    func reloadLocalNotificationCenter(by items: [LensItem] = []) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            DispatchQueue.main.async { [weak self] in
                self?.notifications = notifications
                self?.scheduleNotificationsForAllItems(items)
            }
        }
    }
    
    func openNotificationSettings() {
        guard
            let appSettings = URL(string: UIApplication.openNotificationSettingsURLString), UIApplication.shared.canOpenURL(appSettings)
        else {
            return
        }
        
        UIApplication.shared.open(appSettings, options: [:])
    }
    
    func cancelNotification(for id: String) {
        let dayBeforeId = "\(id)-day-before"
        let dayOfId = "\(id)-day-of"
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [dayBeforeId, dayOfId])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [dayBeforeId, dayOfId])
        
        reloadLocalNotificationCenter()
    }
    
    private func scheduleNotifications(for item: LensItem) {
        let calendar = Calendar.current
        let changeDate = item.changeDate
        
        let daysBeforeDate = calendar.date(byAdding: .day, value: -reminderDays.rawValue, to: changeDate)!
        let daysBeforeContent = createNotificationContent(for: item, referenceDate: daysBeforeDate)
        let daysBeforeId = "\(item.id.uuidString)-day-before"
        
        cancelNotification(for: daysBeforeId)
        scheduleNotification(for: daysBeforeId, at: daysBeforeDate, with: daysBeforeContent)

        let dayOfContent = createNotificationContent(for: item, referenceDate: changeDate)
        let dayOfId = "\(item.id.uuidString)-day-of"
        
        cancelNotification(for: dayOfId)
        scheduleNotification(for: dayOfId, at: changeDate, with: dayOfContent)
    }
    
    private func scheduleNotificationsForAllItems(_ items: [LensItem]) {
        for item in items {
            scheduleNotificationIfNeeded(for: item)
        }
    }

    private func createNotificationContent(for item: LensItem, referenceDate: Date) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        let calendar = Calendar.current
        let lensLabel = item.eyeSide == .both ? "lenses" : "lens"
        
        if let dayBeforeChangeDate = calendar.date(byAdding: .day, value: -1, to: item.changeDate),
           calendar.isDate(referenceDate, inSameDayAs: dayBeforeChangeDate) {
            content.title = "Prepare New Lenses"
            content.body = "Replace your \"\(item.name)\" \(lensLabel) by tomorrow"
        } else if calendar.isDate(referenceDate, inSameDayAs: item.changeDate) {
            content.title = "Time for a Сhange!"
            content.body = "Your \"\(item.name)\" \(lensLabel) has expired"
        } else {
            let verbForm = lensLabel == "lens" ? "needs" : "need"
            content.title = "Prepare New Lenses"
            content.body = "Your \"\(item.name)\" \(lensLabel) \(verbForm) replacing on \(item.changeDate.formattedDate())"
        }

        content.sound = UNNotificationSound.default
        return content
    }

    private func scheduleNotification(for id: String, at date: Date, with content: UNMutableNotificationContent) {
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .month], from: date)
        dateComponents.hour = 10

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Created notification: \(dateComponents.description)")
            }
        }
    }
    
    func scheduleNotificationIfNeeded(for item: LensItem) {
        let existingNotificationIds = notifications.map { $0.identifier }
        let dayBeforeId = "\(item.id.uuidString)-day-before"
        let dayOfId = "\(item.id.uuidString)-day-of"
        
        if ![dayOfId, dayBeforeId].allSatisfy(existingNotificationIds.contains) {
            scheduleNotifications(for: item)
        }
    }
    
    func updateNotificationsForChangedReminderDays(for lensItems: [LensItem]) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        scheduleNotificationsForAllItems(lensItems)
    }
}
