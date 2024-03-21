//
//  LensDashboardView.swift
//  EE Tracker
//
//  Created by Alisher on 03.12.2023.
//

import SwiftUI
import StoreKit
import SwiftData
import TipKit

struct LensDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: LensDashboardViewModel
    
    @State private var showingForm: Bool = false
    @State private var formStatus: LensFormViewModel.Status? = nil
    
    @Environment(\.passStatus) private var passStatus
    @Environment(\.notificationGranted) private var notificationGranted
    
    @Environment(\.colorScheme) private var colorScheme
    var addNewTip = AddNewTip()
    
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
                            LensCarouselHeader(viewModel: self.$viewModel)
                                .padding([.top, .horizontal])
                            
                            LensCarouselView(lenses: self.$viewModel.lensItems, selectedLensItem: self.$viewModel.selectedLensItem)
                                .padding(.bottom, 8)
                            
                            LensTimelineHeader(
                                viewModel: self.$viewModel,
                                showingConfirmation: self.$viewModel.showingConfirmation,
                                formStatus: self.$formStatus ?? .changeable
                            )
                            .padding([.top, .horizontal])
                            
                            if let selectedLensItem = viewModel.selectedLensItem {
                                LensTrackingView(lensItem: selectedLensItem, showingChangables: self.$viewModel.showingChangables)
                                    .padding(.horizontal)
                            }
                            Spacer()
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationTitle("Eye Ease")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        self.formStatus = .new
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundStyle(Color.teal)
                            .tint(.teal)
                    }
                    
                    // TODO: PopoverTip
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        self.viewModel.showingSettings.toggle()
                    } label: {
                        Image(systemName: notificationGranted ? "gear" : "gear.badge")
                            .font(.title3)
                            .symbolRenderingMode(notificationGranted ? .monochrome : .multicolor)
                            .animation(.default, value: notificationGranted)
                    }
                }
                
                if case .notSubscribed = passStatus {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Upgrate to Plus", systemImage: "crown.fill") {
                            self.viewModel.showingSubscriptionsSheet = true
                        }
                        .tint(.teal)
                        .controlSize(.small)
                    }
                }
            })
        }
        .tint(.teal)
        .onChange(of: viewModel.showingChangables, { oldValue, newValue in
            if newValue {
                formStatus = .changeable
            }
        })
        .sheet(isPresented: $viewModel.showingSettings, content: {
            SettingsView()
                .preferredColorScheme(colorScheme)
        })
        .sheet(isPresented: $viewModel.showingSubscriptionsSheet, onDismiss: {
            viewModel.showingSubscriptionsSheet = false
        }, content: {
            SubscriptionShopView()
        })
        .sheet(item: $formStatus) { status in
            switch status {
            case .new:
                LensFormView(status: status) { newLensItem in
                    self.viewModel.addItem(newLensItem)
                    if passStatus != .notSubscribed {
                        self.viewModel.createNotification(by: newLensItem.id)
                    }
                }
            default:
                if let selectedLensItem = viewModel.selectedLensItem {
                    LensFormView(lensItem: selectedLensItem, status: status) { newLensItem in
                        self.viewModel.updateSelectedLens(by: newLensItem)
                        if passStatus != .notSubscribed {
                            self.viewModel.createNotification(by: newLensItem.id)
                        }
                    }
                    .onAppear {
                        self.viewModel.showingChangables = false
                    }
                }
            }
        }
    }
    
    private func delete(_ item: LensItem) {
        self.viewModel.deleteItem(item)
        self.viewModel.cancelNotification(by: item.id)
    }
}

struct LensTimelineHeader: View {
    @Binding var viewModel: LensDashboardViewModel
    @Binding var showingConfirmation: Bool
    @Binding var formStatus: LensFormViewModel.Status

    var body: some View {
        HStack(alignment: .center) {
            Text("Tracking Overview")
                .font(.title)
                .fontWeight(.heavy)
            
            Spacer()
            
            Menu {
                Button {
                    self.formStatus = .editable
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                
                Button {
                    self.formStatus = .changeable
                } label: {
                    Label("Change with new one", systemImage: "gobackward")
                }
                
                Divider()
                
                Button("Delete", role: .destructive) {
                    self.viewModel.showingConfirmation.toggle()
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title2)
            }
            .confirmationDialog("Delete Confirmation", isPresented: $viewModel.showingConfirmation) {
                Button("Delete", role: .destructive) {
                    if let selectedLensItem = viewModel.selectedLensItem  {
                        self.viewModel.deleteItem(selectedLensItem)
                    }
                }
                
                Button("Cancel", role: .cancel) {
                    self.viewModel.showingConfirmation.toggle()
                }
            } message: {
                Text("Are you sure to delete this Lens?")
            }
        }
    }
}

struct LensCarouselHeader: View {
    @Binding var viewModel: LensDashboardViewModel
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            VStack(alignment: .leading) {
                TimelineView(.everyMinute) { context in
                    Text(context.date.formattedDate())
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                }
                
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
                    ForEach(LensSortOrder.allCases) { order in
                        Text(order.rawValue).tag(order)
                    }
                }
                .onChange(of: self.viewModel.sortOrder) { _, newValue in
                    withAnimation {
                        self.viewModel.fetchData()
                    }
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.title2)
            }
        }
    }
}

#Preview {
    LensDashboardView(modelContext: previewContainer.mainContext)
        .modelContainer(previewContainer)
}
