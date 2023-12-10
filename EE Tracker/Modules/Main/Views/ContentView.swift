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
    @Environment(\.modelContext) var modelContext
    @State var selectedLensItem: LensItem?
    @State var isShowingSettings: Bool = false
    @State var isNewLensShowing: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                ZStack(alignment: .bottom) {
                    ScrollView(.vertical) {
                        VStack(spacing: 12) {
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
                    }
                    .frame(maxWidth: .infinity)
                    .scrollIndicators(.hidden)
                    .padding(.horizontal)
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
            }
            .background(Color(.systemGray6))
            .sheet(isPresented: $isShowingSettings, content: {
                SettingsView()
            })
            .sheet(item: $selectedLensItem, content: { lensItem in
                LensView(lensItem: lensItem)
                    .modelContext(modelContext)
            })
            .sheet(isPresented: $isNewLensShowing, content: {
                NewLensView()
            })
            .onDisappear(perform: {
                self.isNewLensShowing = false
            })
            .navigationTitle("My Lens")
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
        modelContext.delete(item)
    }
}

#Preview {
    ContentView()
        .modelContainer(previewContainer)
}
