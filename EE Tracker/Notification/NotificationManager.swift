//
//  NotificationManager.swift
//  EE Tracker
//
//  Created by Alisher Altore on 04.03.2024.
//

import UserNotifications
import UIKit
import Combine
import SwiftUI
import SwiftData

@ModelActor
actor NotificationManager {
    private(set) var notifications: [UNNotificationRequest] = []
    
    private(set) var items: [LensItem] = []
    private(set) static var shared: NotificationManager!
    
    static func createSharedInstance(modelContext: ModelContext) {
        shared = NotificationManager(modelContainer: modelContext.container)
    }
    
    func reloadItems() {
        do {
            items = try modelContext.fetch(FetchDescriptor<LensItem>())
            print("NotificationManager: reloadItems(\(items.count))")
        } catch {
            print("Can't fetch items: \(error)")
        }
    }
    
    private var reminderDays: Int {
        return UserDefaults.standard.integer(forKey: AppStorageKeys.reminderDays)
    }
    
    func requestAuthorization() async throws -> Bool {
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        do {
            let granted = try await notificationCenter.requestAuthorization(options: options)
            return granted
        } catch {
            throw error
        }
    }
    
    func getAuthorizationStatus() async -> UNAuthorizationStatus {
        let notificationCenter = UNUserNotificationCenter.current()
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }
    
    func reloadLocalNotifications() async {
        let notificationCenter = UNUserNotificationCenter.current()
        let notificationRequest = await notificationCenter.pendingNotificationRequests()
        self.notifications = notificationRequest
        print("NotificationManager: reloadLocalNotifications(\(self.notifications.count))")
    }
    
    func cancelNotification(for id: UUID) {
        print("NotificationManager: cancelNotification")
        let notificationCenter = UNUserNotificationCenter.current()
        let dayBeforeId = "\(id.uuidString)-day-before"
        let dayOfId = "\(id.uuidString)-day-of"
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [dayBeforeId, dayOfId])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [dayBeforeId, dayOfId])
    }
    
    func updateNotifications(for item: LensItem) async {
        cancelNotification(for: item.id)
        await scheduleNotifications(for: item)
        await reloadLocalNotifications()
    }
    
    func scheduleNotifications(for item: LensItem) async {
        let calendar = Calendar.current
        let changeDate = item.changeDate
        
        if reminderDays > 0 {
            let daysBeforeDate = calendar.date(byAdding: .day, value: -reminderDays, to: changeDate)!
            let daysBeforeContent = createNotificationContent(for: item, referenceDate: daysBeforeDate)
            let daysBeforeId = "\(item.id.uuidString)-day-before"
            await scheduleNotification(for: daysBeforeId, at: daysBeforeDate, with: daysBeforeContent)
        }

        let dayOfContent = createNotificationContent(for: item, referenceDate: changeDate)
        let dayOfId = "\(item.id.uuidString)-day-of"
        
        await scheduleNotification(for: dayOfId, at: changeDate, with: dayOfContent)
    }
    
    private func createNotificationContent(for item: LensItem, referenceDate: Date) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        let calendar = Calendar.current
        
        if let dayBeforeChangeDate = calendar.date(byAdding: .day, value: -1, to: item.changeDate),
           calendar.isDate(referenceDate, inSameDayAs: dayBeforeChangeDate) {
            content.title = "Prepare new contact lens"
            content.body = "Replace your \"\(item.name)\" contact lens by tomorrow."
        } else if calendar.isDate(referenceDate, inSameDayAs: item.changeDate) {
            content.title = "Time for a change!"
            content.body = "Your \"\(item.name)\" contact lens has expired."
        } else {
            content.title = "Prepare new lenses"
            content.body = "Your \"\(item.name)\" contact lens need replacing on \(item.changeDate.formattedDate())."
        }

        content.sound = UNNotificationSound.default
        return content
    }

    private func scheduleNotification(for id: String, at date: Date, with content: UNMutableNotificationContent) async {
        let notificationCenter = UNUserNotificationCenter.current()
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour], from: date)
        dateComponents.hour = 10

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        do {
            print("NotificationManager scheduleNotification: \(dateComponents.description)")
            try await notificationCenter.add(request)
        } catch {
            print("NotificationManager can't add notification request: \(error)")
        }
    }
    
    func reloadLocalNotificationByItems(_ force: Bool = false) {
        print("NotificationManager: reloadLocalNotificationByItems")
        reloadItems()
        
        if force {
            
            removeNotifications()
            
            Task {
                for item in items {
                    await scheduleNotifications(for: item)
                }
            }
        } else {
            Task {
                await reloadLocalNotifications()
                
                for item in items {
                    let dayBeforeId = "\(item.id.uuidString)-day-before"
                    let dayOfId = "\(item.id.uuidString)-day-of"
                    let existingNotificationIds = notifications.map { $0.identifier }
                    
                    if ![dayOfId, dayBeforeId].allSatisfy(existingNotificationIds.contains) {
                        await scheduleNotifications(for: item)
                    }
                }
            }
        }
    }
    
    func removeNotifications() {
        print("NotificationManager: removeNotifications")

        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        
        self.notifications.removeAll()
    }
}
