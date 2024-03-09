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
    
    var notificationManager = NotificationManager()
    
    var showingSettings: Bool = false
    var showingConfirmation: Bool = false
    var showingSort: Bool = false
    var showingChangables: Bool = false
    var pushNotificationAllowed: Bool = false
    
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
        self.setupNotificationStatusObserver()
        self.setupNotificationRemainderDaysObserver()
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
    
    func deleteItem(_ item: LensItem) {
        selectedLensItem = nil
        withAnimation {
            modelContext.delete(item)
            fetchData()
        }
        notificationManager.cancelNotification(for: item.id.uuidString)
    }
    
    func reloadAuthorizationSatus() {
        notificationManager.reloadAuthorizationSatus()
    }
    
    private func setupNotificationStatusObserver() {
        notificationManager.$authorizationStatus
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                guard let self else { return }
                
                switch status {
                case .notDetermined:
                    self.pushNotificationAllowed = false
                    self.notificationManager.requestAuthorization()
                case .authorized, .provisional:
                    self.pushNotificationAllowed = true
                    self.notificationManager.reloadLocalNotificationCenter(by: lensItems)
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupNotificationRemainderDaysObserver() {
        notificationManager.reminderDaysPublisher
            .print()
            .sink { [weak self] _ in
                guard let self else { return }
                self.notificationManager.reloadLocalNotificationCenter()
                self.notificationManager.updateNotificationsForChangedReminderDays(for: lensItems)
            }
            .store(in: &cancellables)
    }
}
