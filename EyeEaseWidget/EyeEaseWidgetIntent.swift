//
//  EyeEaseWidgetIntent.swift
//  EE Tracker
//
//  Created by Alisher Altore on 03.04.2024.
//

import WidgetKit
import AppIntents
import SwiftData

struct EyeEaseWidgetIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Select Contact Lens"
    static let description = IntentDescription("Select the contact lens to display information")
    
    @Parameter(title: "Contact Lens")
    var lensItem: LensEntity?
    
    init(lensItem: LensEntity? = nil) {
        self.lensItem = lensItem
    }
    
    init() { }
}

struct LensEntity: AppEntity, Identifiable, Hashable {
    var id: LensItem.ID
    var name: String
    var wearDuration: String
    
    init(id: LensItem.ID, name: String, wearDuration: String) {
        self.id = id
        self.name = name
        self.wearDuration = wearDuration
    }
    
    init(from lensItem: LensItem) {
        self.id = lensItem.id
        self.name = lensItem.name
        self.wearDuration = lensItem.wearDuration.rawValue
    }
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name) (\(wearDuration))")
    }
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Select")
    static var defaultQuery = LensEntityQuery()
}

struct LensEntityQuery: EntityQuery, Sendable {
    func entities(for identifiers: [LensItem.ID]) async throws -> [LensEntity] {
        let modelContext = ModelContext(DataManager.sharedModelContainer)
        let entities = try! modelContext.fetch(FetchDescriptor<LensItem>(sortBy: [SortDescriptor(\.createdDate)]))
        return entities.map { LensEntity(from: $0) }
    }
    
    func suggestedEntities() async throws -> [LensEntity] {
        let modelContext = ModelContext(DataManager.sharedModelContainer)
        let entities = try! modelContext.fetch(FetchDescriptor<LensItem>(sortBy: [SortDescriptor(\.createdDate)]))
        return entities.map { LensEntity(from: $0) }
    }
    
    func defaultResult() async -> LensEntity? {
        try? await suggestedEntities().first
    }
}
