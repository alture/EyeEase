//
//  LensDashboardViewModel.swift
//  EE Tracker
//
//  Created by Alisher Altore on 23.02.2024.
//

import SwiftUI
import SwiftData
import Combine

@Observable
final class LensDashboardViewModel {
    var lensItems: [LensItem] = []
    var selectedLensItem: LensItem? = nil
    var sortOrder: LensSortOrder = .oldestFirst
    
    var showingSettings: Bool = false
    var showingConfirmation: Bool = false
    var showingSort: Bool = false
    var showingChangables: Bool = false
    var showingSubscriptionsSheet: Bool = false
    
    private var sortedLensItem: [LensItem] {
        switch sortOrder {
        case .oldestFirst:
            return lensItems.sorted(using: SortDescriptor(\LensItem.changeDate))
        case .newestFirst:
            return lensItems.sorted(using: SortDescriptor(\LensItem.startDate, order: .reverse))
        case .brandName:
            return lensItems.sorted(using: SortDescriptor(\LensItem.name))
        }
    }
    
    private(set) var modelContext: ModelContext
    
    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.fetchData()
    }
    
    func fetchData() {
        let sortDescriptors: [SortDescriptor<LensItem>] = {
            switch sortOrder {
            case .newestFirst:
                return [SortDescriptor(\LensItem.startDate, order: .reverse)]
            case .oldestFirst:
                return [SortDescriptor(\LensItem.changeDate)]
            case .brandName:
                return [SortDescriptor(\LensItem.name)]
            }
        }()
        
        let fetchDescriptor = FetchDescriptor(predicate: nil, sortBy: sortDescriptors)
        do {
            lensItems = try modelContext.fetch(fetchDescriptor)
            if selectedLensItem == nil {
                selectedLensItem = lensItems.first
            }
        } catch {
            print("Can't load items from modelContext: \(error)")
        }
    }
    
    func addItem(_ item: LensItem) {
        withAnimation {
            modelContext.insert(item)
            selectedLensItem = item
            fetchData()
        }
    }
    
    func deleteItem(_ item: LensItem) {
        withAnimation {
            selectedLensItem = nil
            modelContext.delete(item)
            fetchData()
        }
    }
    
    func updateSelectedLens(by item: LensItem) {
        selectedLensItem?.name = item.name
        selectedLensItem?.eyeSide = item.eyeSide
        selectedLensItem?.wearDuration = item.wearDuration
        selectedLensItem?.startDate = item.startDate
        selectedLensItem?.changeDate = item.changeDate
        selectedLensItem?.usedNumber = item.usedNumber
        selectedLensItem?.detail = item.detail
        selectedLensItem?.sphere = item.sphere
        
        fetchData()
    }
    
    func createNotification(by id: UUID) {
        if let notificationManager = NotificationManager.shared {
            Task {
                await notificationManager.scheduleNotifications(for: id)
            }
        }
    }
    
    func cancelNotification(by id: UUID) {
        if let notificationManager = NotificationManager.shared {
            Task {
                await notificationManager.cancelNotification(for: id)
            }
        }
    }
}
