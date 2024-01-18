//
//  EE_TrackerApp.swift
//  EE Tracker
//
//  Created by Alisher on 03.12.2023.
//

import SwiftUI
import SwiftData

@main
struct EE_TrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LensItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
//                .environment(\.font, .system(.body, design: .rounded))
        }
        .modelContainer(previewContainer)
    }
}
