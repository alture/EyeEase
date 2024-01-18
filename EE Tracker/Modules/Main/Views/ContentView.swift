//
//  ContentView.swift
//  EE Tracker
//
//  Created by Alisher on 03.12.2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var lensItems: [LensItem]
    @Environment(\.modelContext) private var modelContext
    @State private var isShowingSettings: Bool = false
    @State private var isNewLensShowing: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                if let pinnedLensItem = lensItems.first(where: { $0.isPinned }) {
                    LensTrackingView()
                        .environmentObject(pinnedLensItem)
                } else {
                    VStack(alignment: .center) {
                        Image(systemName: "pin")
                            .font(.largeTitle)
                        Text("No pinned Lens")
                            .font(.title2)
                    }
                }
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(lensItems) { lensItem in
                                LensItemRow()
                                    .environmentObject(lensItem)
                            }
                        }
                    }
                } header: {
                    HStack {
                        Image(systemName: "circlebadge.2")
                        Text("My Lens")
                    }
                    Text("My Lens")
                }
                .listRowBackground(Color(.systemGroupedBackground))
                .listRowInsets(EdgeInsets())
            }
            .scrollIndicators(.hidden)
            .navigationTitle("EyeEase")
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        self.isNewLensShowing.toggle()
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
        .sheet(isPresented: $isShowingSettings, content: {
            SettingsView()
        })
        .sheet(isPresented: $isNewLensShowing, content: {
            NewLensView()
                .modelContainer(modelContext.container)
        })
        .onDisappear(perform: {
            self.isNewLensShowing = false
        })
        .overlay(content: {
            if lensItems.isEmpty {
                ContentUnavailableView(
                    "No tracking lens",
                    systemImage: "clock.arrow.2.circlepath",
                    description: Text("Add new lense using + button on top")
                )
            }
        })
    }
    
    private func delete(_ item: LensItem) {
        withAnimation {
            modelContext.delete(item)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView()
        .modelContainer(previewContainer)
}
