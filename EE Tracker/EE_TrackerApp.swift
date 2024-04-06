//
//  EE_TrackerApp.swift
//  EE Tracker
//
//  Created by Alisher on 03.12.2023.
//

import SwiftUI
import SwiftData
import TipKit

@main
struct EE_TrackerApp: App {
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(DataManager.sharedModelContainer)
    }
    
    init() {
        NotificationManager.createSharedInstance(modelContext: DataManager.sharedModelContainer.mainContext)
        PassManager.createSharedInstance()
        
        try? Tips.configure()
    }
}
