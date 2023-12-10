//
//  DataSourceModel.swift
//  EE Tracker
//
//  Created by Alisher on 10.12.2023.
//

import Foundation
import SwiftData

final class DataSourceModel {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func appendItem(_ item: LensItem) {
        modelContext.insert(item)
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func removeItem(_ item: LensItem) {
        modelContext.delete(item)
    }
    
    func fetchItems() -> [LensItem] {
        do {
            return try modelContext.fetch(FetchDescriptor<LensItem>())
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
