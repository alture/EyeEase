//
//  NotificationGrantedKey.swift
//  EE Tracker
//
//  Created by Alisher Altore on 18.03.2024.
//

import SwiftUI

private struct NotificationGrantedKey: EnvironmentKey {
    static let defaultValue: Bool = UserDefaults.standard.bool(forKey: AppStorageKeys.notificationGranted)
}

extension EnvironmentValues {
    var notificationGranted: Bool {
        get { self[NotificationGrantedKey.self] }
        set { self[NotificationGrantedKey.self] = newValue}
    }
}

extension View {
    func notificationGranted(_ value: Bool) -> some View {
        environment(\.notificationGranted, value)
    }
}
