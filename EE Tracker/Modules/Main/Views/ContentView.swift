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
    @State var selectedLensItem: LensItem?
    @State var isShowingSettings: Bool = false
    @State var isNewLensShowing: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                List {
                    ForEach(lensItems) { lensItem in
                        LensItemRow(lensItem: lensItem)
                            .onTapGesture {
                                self.selectedLensItem = lensItem
                            }
                            .contextMenu {
                                Button {
                                    self.delete(lensItem)
                                } label: {
                                    Text("Delete")
                                    Image(systemName: "trash")
                                }
                            }
                    }
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
                
                Button(action: {
                    self.isNewLensShowing = true
                }, label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.teal)
                        .frame(width: 60, height: 60)
                })
            }
            .sheet(isPresented: $isShowingSettings, content: {
                SettingsView()
            })
            .sheet(item: $selectedLensItem, content: { lensItem in
                LensView()
                    .environmentObject(lensItem)
                    .modelContainer(modelContext.container)
            })
            .sheet(isPresented: $isNewLensShowing, content: {
                NewLensView()
                    .modelContainer(modelContext.container)
            })
            .onDisappear(perform: {
                self.isNewLensShowing = false
            })
            .navigationTitle("My Lens")
            .overlay(content: {
                if lensItems.isEmpty {
                    ContentUnavailableView(
                        "No tracking lens",
                        systemImage: "clock.arrow.2.circlepath",
                        description: Text("Add new lense using + button bellow")
                    )
                }
            })
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        self.isShowingSettings.toggle()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundStyle(Color.teal)
                    }
                }
            })
        }
    }
    
    private func delete(_ item: LensItem) {
        withAnimation {
            modelContext.delete(item)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(previewContainer)
}
