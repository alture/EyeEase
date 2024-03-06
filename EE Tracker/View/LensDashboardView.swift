//
//  LensDashboardView.swift
//  EE Tracker
//
//  Created by Alisher on 03.12.2023.
//

import SwiftUI
import SwiftData

struct LensDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: LensDashboardViewModel
    @Bindable private var notificationManager = NotificationManager()
    
    @State private var showingSettings: Bool = false
    @State private var showingConfirmation: Bool = false
    @State private var showingSort: Bool = false
    @State private var showingChangables: Bool = false
    @State private var pushNotificationAllowed: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    
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
                                showingConfirmation: self.$showingConfirmation
                            )
                            .padding([.top, .horizontal])
                            
                            if let selectedLensItem = viewModel.selectedLensItem {
                                let _ = print("Start: \(selectedLensItem.startDate.description(with: .current))")
                                let _ = print("End: \(selectedLensItem.changeDate.description(with: .current))")
                                LensTrackingView(lensItem: selectedLensItem, showingChangables: self.$showingChangables)
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
                        Image(systemName: pushNotificationAllowed ? "gear" : "gear.badge")
                            .font(.title3)
                            .symbolRenderingMode(pushNotificationAllowed ? .monochrome : .multicolor)
                    }
                }
            })
            .onAppear() {
                self.notificationManager.requestAuthorization()
                self.notificationManager.reloadAuthorizationSatus()
            }
            .onChange(of: notificationManager.authorizationStatus) { oldValue, newValue in
                switch newValue {
                case .notDetermined:
                    self.pushNotificationAllowed = false
                case .authorized:
                    self.pushNotificationAllowed = true
                default:
                    break
                }
            }
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
                .preferredColorScheme(colorScheme)
        })
    }
    
    private func delete(_ item: LensItem) {
        notificationManager.removeNotificationRequests(by: item.id.uuidString)
        withAnimation {
            self.viewModel.deleteItem(item)
        }
    }
    
    private func getCurrentDate(with format: String = "EEEE, MMM, d") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: Date())
    }
}

struct LensTimelineHeader: View {
    @Binding var viewModel: LensDashboardViewModel
    @Binding var showingConfirmation: Bool
    var body: some View {
        HStack(alignment: .center) {
            Text("Tracking Overview")
                .font(.title)
                .fontWeight(.heavy)
            
            Spacer()
            
            Menu {
                NavigationLink {
                    LensFormView(lensItem: $viewModel.selectedLensItem, status: .editable)
                        .onDisappear {
                            withAnimation {
                                self.viewModel.fetchData(selectDefaultLens: false)
                            }
                        }
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                
                NavigationLink {
                    LensFormView(lensItem: $viewModel.selectedLensItem, status: .changeable)
                        .onDisappear {
                            withAnimation {
                                self.viewModel.fetchData(selectDefaultLens: false)
                            }
                        }
                } label: {
                    Label("Change with new one", systemImage: "gobackward")
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
    @AppStorage("reminderDays") var reminderDays: ReminderDays = .three
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
                    ForEach(LensSortOrder.allCases) { order in
                        Text(order.rawValue).tag(order)
                    }
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
