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
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            LenseItem.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: LenseViewModel())
                .preferredColorScheme(.light)
        }
//        .modelContainer(sharedModelContainer)
    }
}
