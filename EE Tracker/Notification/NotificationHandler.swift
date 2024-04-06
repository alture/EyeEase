//
//  NotificationHandler.swift
//  EE Tracker
//
//  Created by Alisher Altore on 06.04.2024.
//

import SwiftUI

public class NotificationHandler: ObservableObject {
    public static let shared = NotificationHandler()
    
    @Published private(set) var latestNotification: UNNotificationResponse? = .none
    
    public func handle(notification: UNNotificationResponse) {
        self.latestNotification = notification
    }
}
