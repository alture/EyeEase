//
//  EyeEaseTimelineProvider.swift
//  EE Tracker
//
//  Created by Alisher Altore on 05.04.2024.
//

import Foundation
import SwiftData
import WidgetKit

struct EyeEaseWidgetEntry: TimelineEntry {
    var date: Date
    var lensItem: LensItem?
    
    static var empty: Self {
        Self(date: .now)
    }
}

struct EyeEaseTimelineProvider: AppIntentTimelineProvider {
    
    let modelContext: ModelContext
    
    init() {
        modelContext = ModelContext(DataManager.sharedModelContainer)
    }
    
    func lensItems(for configuration: EyeEaseWidgetIntent) -> [LensItem] {
        if let id = configuration.lensItem?.id {
            try! modelContext.fetch(FetchDescriptor<LensItem>(predicate: #Predicate { $0.id == id }))
        } else {
            try! modelContext.fetch(FetchDescriptor<LensItem>(sortBy: [SortDescriptor(\.createdDate)]))
        }
    }
    
    func timeline(for configuration: EyeEaseWidgetIntent, in context: Context) async -> Timeline<EyeEaseWidgetEntry> {
        let lensItems = lensItems(for: configuration)
        guard !lensItems.isEmpty else {
            return Timeline(entries: [.empty], policy: .never)
        }
        
        let entries = lensItems.map {
            EyeEaseWidgetEntry(date: Date.now, lensItem: $0)
        }
        
        return Timeline(entries: entries, policy: .after(Date.now.nextOfDay))
    }
    
    func snapshot(for configuration: EyeEaseWidgetIntent, in context: Context) async -> EyeEaseWidgetEntry {
        let lensItems = lensItems(for: configuration)
        
        guard let selectedLensItem = lensItems.first else {
            return .empty
        }
        
        return EyeEaseWidgetEntry(date: Date.now, lensItem: selectedLensItem)
    }
    
    func placeholder(in context: Context) -> EyeEaseWidgetEntry {
        let lensItem = try! modelContext.fetch(FetchDescriptor<LensItem>(sortBy: [SortDescriptor(\.createdDate)]))
        return EyeEaseWidgetEntry(date: .now, lensItem: lensItem.first)
    }
}

