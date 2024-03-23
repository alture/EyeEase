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
    private(set) var notifications: [UNNotificationRequest] = [] {
        didSet {
            print("NotificationManager: notificationCount: \(notifications.count)")
        }
    }
    
    private(set) var items: [LensItem] = []
    private(set) static var shared: NotificationManager!
    
    static func createSharedInstance(modelContext: ModelContext) {
        shared = NotificationManager(modelContainer: modelContext.container)
    }
    
    func reloadItems() {
        do {
            print("NotificationManager: reloadItems")
            items = try modelContext.fetch(FetchDescriptor<LensItem>())
        } catch {
            print("Can't fetch items: \(error)")
        }
    }
    
    @AppStorage(AppStorageKeys.reminderDays) var reminderDays: ReminderDays = .none
    
    var reminderDaysPublisher: AnyPublisher<Void, Never> {
        reminderDaysSubject.eraseToAnyPublisher()
    }
    
    private var reminderDaysSubject = PassthroughSubject<Void, Never>()
    
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
        print("NotificationManager: reloadLocalNotifications")
        let notificationCenter = UNUserNotificationCenter.current()
        let notificationRequest = await notificationCenter.pendingNotificationRequests()
        self.notifications = notificationRequest
    }
    
    func cancelNotification(for id: UUID) {
        print("NotificationManager: cancelNotification")
        let notificationCenter = UNUserNotificationCenter.current()
        let dayBeforeId = "\(id.uuidString)-day-before"
        let dayOfId = "\(id.uuidString)-day-of"
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [dayBeforeId, dayOfId])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [dayBeforeId, dayOfId])
    }
    
    func scheduleNotifications(for id: UUID) async {
        await reloadLocalNotifications()
        reloadItems()
        guard let item = items.first(where: { $0.id == id } ) else { return }
        cancelNotification(for: id)
        
        let calendar = Calendar.current
        let changeDate = item.changeDate
        
        if reminderDays != .none {
            let daysBeforeDate = calendar.date(byAdding: .day, value: -reminderDays.rawValue, to: changeDate)!
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
        let lensLabel = item.eyeSide == .both ? "lenses" : "lens"
        
        if let dayBeforeChangeDate = calendar.date(byAdding: .day, value: -1, to: item.changeDate),
           calendar.isDate(referenceDate, inSameDayAs: dayBeforeChangeDate) {
            content.title = "Prepare New Lenses"
            content.body = "Replace your \"\(item.name)\" \(lensLabel) by tomorrow."
        } else if calendar.isDate(referenceDate, inSameDayAs: item.changeDate) {
            content.title = "Time for a Сhange!"
            content.body = "Your \"\(item.name)\" \(lensLabel) has expired."
        } else {
            let verbForm = lensLabel == "lens" ? "needs" : "need"
            content.title = "Prepare New Lenses"
            content.body = "Your \"\(item.name)\" \(lensLabel) \(verbForm) replacing on \(item.changeDate.formattedDate())."
        }

        content.sound = UNNotificationSound.default
        return content
    }

    private func scheduleNotification(for id: String, at date: Date, with content: UNMutableNotificationContent) async {
        let notificationCenter = UNUserNotificationCenter.current()
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .month], from: date)
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

        let notificationCenter = UNUserNotificationCenter.current()
        
        if force {
            notificationCenter.removeAllPendingNotificationRequests()
            notificationCenter.removeAllDeliveredNotifications()
            
            for item in items {
                Task(priority: .background) {
                    await scheduleNotifications(for: item.id)
                }
            }
        } else {
            for item in items {
                Task(priority: .background) {
                    let dayBeforeId = "\(item.id.uuidString)-day-before"
                    let dayOfId = "\(item.id.uuidString)-day-of"
                    let existingNotificationIds = notifications.map { $0.identifier }
                    
                    if ![dayOfId, dayBeforeId].allSatisfy(existingNotificationIds.contains) {
                        await scheduleNotifications(for: item.id)
                    }
                }
            }
        }
    }
    
    func removeAllNotification() {
        print("NotificationManager: removeAllNotification")

        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests()
    }
}
