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
    @Query private var lensItems: [LensItem]
    @Environment(\.modelContext) private var modelContext
    @State private var isShowingSettings: Bool = false
    @State private var showingConfirmation: Bool = false
    @State private var selectedLensItem: LensItem?
    @State private var isShowingSortButton: Bool = false
    @State private var sortOrder: LensSortOrder = .olderToNew
    
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
                            if lensItems.count > 1 {
                                ContentViewHeader(title: "My Lens", content: {
                                    Menu {
                                        Text("Sort by:")
                                            .foregroundStyle(.secondary)
                                        Divider()
                                        ForEach(LensSortOrder.allCases) { sortValue in
                                            Button {
                                                withAnimation(.easeInOut) {
                                                    self.sortOrder = sortValue
                                                }
                                            } label: {
                                                HStack {
                                                    Text(sortValue.rawValue)
                                                    Spacer()
                                                    if sortValue.rawValue == self.sortOrder.rawValue {
                                                        Image(systemName: "checkmark")
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        Image(systemName: "line.3.horizontal.decrease")
                                            .font(.title2)
                                    }
                                })
                                .padding(.top)
                                .padding(.horizontal)
                                
                                LensCarouselView(sortOrder: self.sortOrder, didSelectItem: { lensItem in
                                    lensItems.forEach { $0.isSelected = lensItem.id == $0.id }
                                    self.selectedLensItem = lensItems.first(where: { $0.isSelected } )
                                })
                                    .padding(.bottom, 8)
                                Divider()
                            }
                            
                            if let selectedLensItem {
                                ContentViewHeader(title: "Timeline") {
                                    Menu {
                                        NavigationLink {
                                            LensCreateOrEditView(lensItem: selectedLensItem, status: .edit)
                                                .environmentObject(selectedLensItem)
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        
                                        NavigationLink {
                                            LensCreateOrEditView(lensItem: selectedLensItem, status: .change)
                                                .environmentObject(selectedLensItem)
                                        } label: {
                                            Label("Replace with new one", systemImage: "gobackward")
                                        }
                                        
                                        Divider()
                                        
                                        Button("Delete", role: .destructive) {
                                            self.showingConfirmation.toggle()
                                        }
                                    } label: {
                                        Image(systemName: "ellipsis.circle")
                                            .font(.title2)
                                    }
                                }
                                .padding(.top)
                                .padding(.horizontal)
                                
                                LensTrackingView()
                                    .environmentObject(selectedLensItem)
                                    .padding(.horizontal)
                                Spacer()
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationTitle("EyeEase")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        LensCreateOrEditView(lensItem: LensItem(), status: .new)
                            .modelContainer(modelContext.container)
                            .onDisappear {
                                self.selectedLensItem = lensItems.first { $0.isSelected }
                            }
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
        .confirmationDialog("Delete Confirmation", isPresented: $showingConfirmation) {
            Button("Delete", role: .destructive) {
                if let selectedLensItem {
                    self.delete(selectedLensItem)
                }
            }
            
            Button("Cancel", role: .cancel) {
                self.showingConfirmation.toggle()
            }
        } message: {
            Text("Are you sure to delete this Lens?")
        }

        .tint(.teal)
        .sheet(isPresented: $isShowingSettings, content: {
            SettingsView()
        })
        .onAppear() {
            self.selectedLensItem = lensItems.first(where: { $0.isSelected } )
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
            lensItems.first?.isSelected = true
            self.selectedLensItem = lensItems.first(where: { $0.isSelected } )
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

struct ContentViewHeader<Content: View>: View {
    var title: String
    @ViewBuilder var content: () -> Content
    var body: some View {
        HStack {
            Text(title)
                .font(.title)
                .bold()
            Spacer()
            content()

        }
    }
}

#Preview {
    ContentView()
        .modelContainer(previewContainer)
}
