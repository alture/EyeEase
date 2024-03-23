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
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .automatic)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
    
    init() {
        NotificationManager.createSharedInstance(modelContext: sharedModelContainer.mainContext)
        PassManager.createSharedInstance()
        
        try? Tips.configure()
    }
}
