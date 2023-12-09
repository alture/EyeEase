//
//  ContentView.swift
//  EE Tracker
//
//  Created by Alisher on 03.12.2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {
//    @Environment(\.modelContext) private var modelContext
    @StateObject var viewModel: LenseViewModel
    @State var isShowingSettings: Bool = false
    @State var selectedLensItem: LensItem?
    @State var isNewLensShowing: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                ZStack(alignment: .bottom) {
                    ScrollView(.vertical) {
                        VStack(spacing: 12) {
                            ForEach(viewModel.lenses) { lensItem in
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
                        self.isNewLensShowing.toggle()
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
            })
            .sheet(isPresented: $isNewLensShowing, content: {
                NewLensView()
                    .environmentObject(self.viewModel)
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
        viewModel.remove(lense: item)
    }
}

#Preview {
    ContentView(viewModel: LenseViewModel())
//        .modelContainer(for: LenseItem.self, inMemory: true)
}
