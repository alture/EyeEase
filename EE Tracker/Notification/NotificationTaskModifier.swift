//
//  NotificationTaskModifier.swift
//  EE Tracker
//
//  Created by Alisher Altore on 18.03.2024.
//

import SwiftUI

struct NotificationTaskModifier: ViewModifier {
    @AppStorage(AppStorageKeys.notificationGranted) private var isGranted: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    
    func body(content: Content) -> some View {
        content
            .task {
                await checkAndUpdateNotificationStatus()
            }
            .onChange(of: scenePhase, { oldValue, newValue in
                if newValue == .active {
                    Task {
                        await checkAndUpdateNotificationStatus()
                    }
                }
            })
            .notificationGranted(isGranted)
    }
    
    private func checkAndUpdateNotificationStatus() async {
        guard let notificationManager = NotificationManager.shared else {
            fatalError("Notification manager was nil")
        }
        
        let status = await notificationManager.getAuthorizationStatus()
        
        switch status {
        case .notDetermined:
            do {
                self.isGranted = try await notificationManager.requestAuthorization()
            } catch {
                self.isGranted = false
                print("Can't request authorization: \(error)")
            }
        case .authorized, .provisional:
            self.isGranted = true
            await NotificationManager.shared.reloadLocalNotifications()
        default:
            self.isGranted = false
        }
    }
}

extension View {
    func notificationGrantedTask() -> some View {
        modifier(NotificationTaskModifier())
    }
}
