//
//  ContentView.swift
//  EE Tracker
//
//  Created by Alisher on 03.12.2023.
//

import SwiftUI
import SwiftData
import UserNotifications

struct ContentView: View {
    @Query(sort: \LensItem.startDate) var lensItems: [LensItem]
    @Environment(\.modelContext) private var modelContext
    @State private var isShowingSettings: Bool = false
    @State private var selectedLensItem: LensItem?
    
    var body: some View {
        NavigationStack {
            Group {
                if lensItems.isEmpty {
                    ContentUnavailableView(
                        "No tracking lens",
                        systemImage: "clock.arrow.2.circlepath",
                        description: Text("Add new lense using + button on top")
                    )
                } else {
                    ScrollView {
                        VStack {
                            LensCarouselView(selectedLens: $selectedLensItem)
                            
                            if let selectedLensItem {
                                LensTrackingView(removeAction: postContent)
                                    .environmentObject(selectedLensItem)
                                    .padding(.horizontal)
                            }
                            Spacer()
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationTitle("EyeEase")
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        LensCreateOrEditView(lensItem: LensItem(), status: .new)
                            .modelContainer(modelContext.container)
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundStyle(Color.teal)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        self.isShowingSettings.toggle()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundStyle(Color.teal)
                    }
                }
            })
        }
        .tint(.teal)
        .sheet(isPresented: $isShowingSettings, content: {
            SettingsView()
        })
        .onAppear() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("Permission approvved!")
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func delete(_ item: LensItem) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])
        withAnimation {
            modelContext.delete(item)
            selectedLensItem = lensItems.first
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func postContent() {
        guard let selectedLensItem else { return }
        delete(selectedLensItem)
    }
}

#Preview {
    ContentView()
        .modelContainer(previewContainer)
}
