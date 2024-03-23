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
    @Query(sort: \LensItem.createdDate) var lensItems: [LensItem]
    
    @State private var viewModel: LensDashboardViewModel = LensDashboardViewModel()
    
    @Environment(\.passStatus) private var passStatus
    @Environment(\.notificationGranted) private var notificationGranted
    
    @Environment(\.colorScheme) private var colorScheme
    var addNewTip = AddNewTip()
    
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
                            TodayDateView()
                                .padding([.top, .horizontal])
                            
                            LensCarouselView()
                                .padding(.bottom, 8)
                            
                            TrackingOverviewHeaderView()
                                .padding([.top, .horizontal])
                            
                            LensTrackingView()
                                .padding(.horizontal)
                            
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
                        if case .notSubscribed = passStatus, lensItems.count > 1 {
                            self.viewModel.showingSubscriptionsSheet.toggle()
                        } else {
                            self.viewModel.showingNew.toggle()
                        }

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
        .sheet(isPresented: $viewModel.showingSettings, onDismiss: {
            self.viewModel.showingSettings = false
        }, content: {
            SettingsView()
                .preferredColorScheme(colorScheme)
        })
        .sheet(isPresented: $viewModel.showingSubscriptionsSheet, onDismiss: {
            viewModel.showingSubscriptionsSheet = false
        }, content: {
            SubscriptionShopView()
        })
        .sheet(isPresented: $viewModel.showingNew) {
            viewModel.showingNew = false
        } content: {
            LensFormView(state: .new, lensItem: nil)
        }
    }
}

struct TrackingOverviewHeaderView: View {
    @Environment(NavigationContext.self) private var navigationContext
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingConfirmation: Bool = false
    @State private var showingEdit: Bool = false
    @State private var showingChange: Bool = false

    var body: some View {
        HStack(alignment: .center) {
            Text("Tracking Overview")
                .font(.title)
                .fontWeight(.heavy)
            
            Spacer()
            
            Menu {
                Button {
                    self.showingEdit.toggle()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                
                Button {
                    self.showingChange.toggle()
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
            .disabled(navigationContext.selectedLensItem == nil)
            .confirmationDialog("Delete Confirmation", isPresented: $showingConfirmation) {
                Button("Delete", role: .destructive) {
                    withAnimation {
                        if let selectedLensItem = navigationContext.selectedLensItem {
                            self.modelContext.delete(selectedLensItem)
                            navigationContext.selectedLensItem = nil
                        }
                    }
                }
                
                Button("Cancel", role: .cancel) {
                    self.showingConfirmation.toggle()
                }
            } message: {
                Text("Are you sure to delete this Lens?")
            }
        }
        .sheet(isPresented: $showingEdit) {
            LensFormView(state: .editable, lensItem: navigationContext.selectedLensItem)
        }
        .sheet(isPresented: $showingChange) {
            LensFormView(state: .changeable, lensItem: navigationContext.selectedLensItem)
        }
    }
}

struct TodayDateView: View {
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
        }
    }
}

#Preview {
    LensDashboardView()
        .modelContainer(previewContainer)
        .environment(NavigationContext(selectedLensItem: SampleData.content[0]))
}
