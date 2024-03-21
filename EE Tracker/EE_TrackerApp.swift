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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LensItem.self,
            Sphere.self,
            LensDetail.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @AppStorage(AppStorageKeys.appAppearance) private var appAppearance: AppAppearance = .system

    var body: some Scene {
        WindowGroup {
            LensDashboardView(modelContext: sharedModelContainer.mainContext)
                .preferredColorScheme(appAppearance == .system ? .none : (appAppearance == .dark ? .dark : .light ))
                .notificationGrantedTask()
                .subscriptionShop()
                .fontDesign(.rounded)
        }
        .modelContainer(sharedModelContainer)
    }
    
    init() {
        NotificationManager.createSharedInstance(modelContext: sharedModelContainer.mainContext)
        PassManager.createSharedInstance()
        
        try? Tips.resetDatastore()
        try? Tips.configure()
    }
}
