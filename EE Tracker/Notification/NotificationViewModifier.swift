//
//  NotificationViewModifier.swift
//  EE Tracker
//
//  Created by Alisher Altore on 06.04.2024.
//

import SwiftUI

struct NotificationViewModifier: ViewModifier {
    private let onNotification: (UNNotificationResponse) -> Void
    
    init(onNotification: @escaping (UNNotificationResponse) -> Void) {
        self.onNotification = onNotification
    }
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationHandler.shared.$latestNotification) { notification in
                guard let notification else { return }
                onNotification(notification)
            }
    }
}

extension View {
    func onNotification(perform action: @escaping (UNNotificationResponse) -> Void) -> some View {
        modifier(NotificationViewModifier(onNotification: action))
    }
}
