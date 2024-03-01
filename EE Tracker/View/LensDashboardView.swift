//
//  LensDashboardView.swift
//  EE Tracker
//
//  Created by Alisher on 03.12.2023.
//

import SwiftUI
import SwiftData
import UserNotifications

struct LensDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: LensDashboardViewModel
    
    @State private var showingSettings: Bool = false
    @State private var showingConfirmation: Bool = false
    @State private var showingSort: Bool = false
    @State private var showingChangables: Bool = false
    
    init(modelContext: ModelContext) {
        let viewModel = LensDashboardViewModel(modelContext: modelContext)
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.lensItems.isEmpty {
                    ContentUnavailableView(
                        "No tracking lens",
                        systemImage: "clock.arrow.2.circlepath",
                        description: Text("Add new lense using + button on top")
                    )
                } else {
                    ScrollView {
                        VStack {
                            if viewModel.lensItems.count > 1 {
                                LensCarouselHeader(viewModel: self.$viewModel)
                                    .padding(.top)
                                    .padding(.horizontal)
                                    .transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)).combined(with: .opacity))
                                
                                LensCarouselView(lenses: self.$viewModel.lensItems, selectedLensItem: self.$viewModel.selectedLensItem)
                                    .padding(.bottom, 8)
                                    .transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)).combined(with: .opacity))
                            }
                            
                            LensTimelineHeader(
                                viewModel: self.$viewModel,
                                showingConfirmation: self.$showingConfirmation
                            )
                            .padding(.top)
                            .padding(.horizontal)
                            
                            if let selectedLensItem = viewModel.selectedLensItem {
                                LensTrackingView(lensItem: .constant(selectedLensItem), showingChangables: self.$showingChangables)
                                .padding(.horizontal)
                            }
                            Spacer()
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationTitle("EyeEase")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showingChangables, destination: {
                LensFormView(lensItem: self.$viewModel.selectedLensItem, status: .changeable)
            })
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        LensFormView(status: .new)
                            .onDisappear {
                                withAnimation {
                                    self.viewModel.fetchData()
                                }
                            }
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundStyle(Color.teal)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        self.showingSettings.toggle()
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
                if let selectedLensItem = viewModel.selectedLensItem  {
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
        .sheet(isPresented: $showingSettings, content: {
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
            self.viewModel.deleteItem(item)
        }
    }
}

struct LensTimelineHeader: View {
    @Binding var viewModel: LensDashboardViewModel
    @Binding var showingConfirmation: Bool
    var body: some View {
        HStack(alignment: .center) {
            Text("Timeline")
                .font(.title)
                .fontWeight(.heavy)
            
            Spacer()
            
            Menu {
                NavigationLink {
                    LensFormView(lensItem: $viewModel.selectedLensItem, status: .editable)
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                
                NavigationLink {
                    LensFormView(lensItem: $viewModel.selectedLensItem, status: .changeable)
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
    }
}

struct LensCarouselHeader: View {
    @Binding var viewModel: LensDashboardViewModel
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            VStack(alignment: .leading) {
                Text(self.getCurrentDate().uppercased())
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                
                Text("Today")
                    .font(.title)
                    .fontWeight(.heavy)
            }
            
            Spacer()
            
            Menu {
                Text("Sort by:")
                    .foregroundStyle(.secondary)
                Divider()
                Picker("Sort Order", selection: $viewModel.sortOrder) {
                    Text("New to Older").tag(LensSortOrder.newToOlder)
                    Text("Older to New").tag(LensSortOrder.olderToNew)
                    Text("Brand Name").tag(LensSortOrder.brandName)
                }
                .onChange(of: self.viewModel.sortOrder) { _, newValue in
                    withAnimation {
                        self.viewModel.fetchData(selectDefaultLens: false)
                    }
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.title2)
            }
        }
    }
    
    private func getCurrentDate(with format: String = "EEEE, MMM, d") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: Date())
    }
}

#Preview {
    LensDashboardView(modelContext: previewContainer.mainContext)
        .modelContainer(previewContainer)
}
