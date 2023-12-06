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
    @State var lenses: [LensItem] = [
        .init(name: "Lens Item 1", specs: .default),
        .init(name: "Lens Item 2", specs: .default),
        .init(name: "Lens Item 3", specs: .default),
        .init(name: "Lens Item 4", specs: .default),
        .init(name: "Lens Item 5", specs: .default),
    ]
    @State var isShowingSettings: Bool = false
    @State var selectedLensItem: LensItem?
    @State var isNewLensShowing: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                ZStack(alignment: .bottom) {
                    ScrollView(.vertical) {
                        VStack(spacing: 12) {
                            ForEach(lenses) { lensItem in
                                LensItemRow(lensItem: lensItem)
                                    .onTapGesture {
                                        self.selectedLensItem = lensItem
                                    }
                            }
                        }
                    }
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
                EmptyView()
            })
            .sheet(isPresented: $isNewLensShowing, content: {
                LensView(name: "", wearDuration: .monthly, startDate: Date(), color: .clear)
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
}

#Preview {
    ContentView()
//        .modelContainer(for: LenseItem.self, inMemory: true)
}
