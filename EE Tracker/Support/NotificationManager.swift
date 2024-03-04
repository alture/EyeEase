//
//  NotificationManager.swift
//  EE Tracker
//
//  Created by Alisher Altore on 04.03.2024.
//

import UserNotifications
import Observation
import UIKit
import SwiftUI

@Observable
final class NotificationManager {
    private(set) var notifications: [UNNotificationRequest] = []
    private(set) var authorizationStatus: UNAuthorizationStatus?
    
    func reloadAuthorizationSatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                print("\(settings.authorizationStatus)")
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { isGranted, _ in
            DispatchQueue.main.async {
                self.authorizationStatus = isGranted ? .authorized : .denied
            }
        }
    }
    
    func reloadLocalNotificationCenter() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            DispatchQueue.main.async {
                print("Reload existing notification")
                self.notifications = notifications
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
    
    func removeNotificationRequests(by id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
        reloadLocalNotificationCenter()
    }
}
