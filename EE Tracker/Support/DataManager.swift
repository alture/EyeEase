//
//  DataManager.swift
//  EE Tracker
//
//  Created by Alisher Altore on 05.04.2024.
//

import Foundation
import SwiftData

final class DataManager {
    static let shared = DataManager()
    static var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LensItem.self,
            Sphere.self,
            LensDetail.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
