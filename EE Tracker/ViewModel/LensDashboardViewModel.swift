//
//  LensDashboardViewModel.swift
//  EE Tracker
//
//  Created by Alisher Altore on 23.02.2024.
//

import SwiftUI
import SwiftData
import Observation

extension LensDashboardView {
    @Observable
    final class LensDashboardViewModel: ObservableObject {
        var lensItems: [LensItem] = []
        var selectedLensItem: LensItem? = nil
        var sortOrder: LensSortOrder = .olderToNew
        
        private var sortedLensItem: [LensItem] {
            switch sortOrder {
            case .olderToNew:
                return lensItems.sorted(using: SortDescriptor(\LensItem.changeDate))
            case .newToOlder:
                return lensItems.sorted(using: SortDescriptor(\LensItem.startDate, order: .reverse))
            case .brandName:
                return lensItems.sorted(using: SortDescriptor(\LensItem.name))
            }
        }
        
        private(set) var modelContext: ModelContext
        
        init(modelContext: ModelContext) {
            self.modelContext = modelContext
            fetchData()
        }
        
        func fetchData(selectDefaultLens: Bool = true) {
            let sortDescriptors: [SortDescriptor<LensItem>] = {
                switch sortOrder {
                case .newToOlder:
                    return [SortDescriptor(\LensItem.startDate, order: .reverse)]
                case .olderToNew:
                    return [SortDescriptor(\LensItem.changeDate)]
                case .brandName:
                    return [SortDescriptor(\LensItem.name)]
                }
            }()
            
            let fetchDescriptor = FetchDescriptor(predicate: nil, sortBy: sortDescriptors)
            do {
                lensItems = try modelContext.fetch(fetchDescriptor)
                if selectDefaultLens {
                    self.selectedLensItem = lensItems.first
                }
            } catch {
                print("Can't load items from modelContext: \(error)")
            }
        }
        
        func deleteItem(_ item: LensItem) {
            modelContext.delete(item)
            fetchData()
        }
//        func setNew(sortOrder: LensSortOrder) {
//            print("NewOrder: \(sortOrder.rawValue)")
//            self.sortOrder = sortOrder
//            fetchData()
//        }
    }
}
