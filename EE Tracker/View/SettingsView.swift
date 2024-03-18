//
//  SettingsView.swift
//  EE Tracker
//
//  Created by Alisher on 04.12.2023.
//

import SwiftUI
import StoreKit

enum ReminderDays: Int, Identifiable, CustomStringConvertible, CaseIterable {
    case none = 0
    case one
    case two
    case three
    case four
    case five
    case six
    case seven
    
    var description: String {
        switch self {
        case .none:
            return "None"
        case .one:
            return "\(self.rawValue) day before"
        default:
            return "\(self.rawValue) days before"
        }
    }
    
    var id: Self {
        return self
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.requestReview) var requestReview
    
    @Environment(\.passStatus) private var passStatus
    @Environment(\.passIDs.group) private var passGroupID
    @Environment(\.notificationGranted) private var notificationAllowed
    
    private var hasPass: Bool {
        if case .notSubscribed = passStatus { false } else { true }
    }
    
    @AppStorage(AppStorageKeys.appAppearance) var appAppearance: AppAppearance = .system
    
    @State private var presentingPassSheet: Bool = false
    @State private var presentingManagePassSheet = false
    @AppStorage(AppStorageKeys.reminderDays) var reminderDays: ReminderDays = .none
    
    var body: some View {
        NavigationStack {
            if !notificationAllowed && hasPass {
                GroupBox(label:
                    Label("Notifications are disabled", systemImage: "info.circle")
                ) {
                    Text("Turn on push notifications below to get reminders for lens replacement. Stay on track with your eye care!")
                        .font(.footnote)
                        .padding(.top, 2.0)
                }
                .backgroundStyle(Color.yellow.opacity(0.7))
                .padding(.horizontal)
            }
            
            Form {
                Section(header: Text("Account")) {
                    Button {
                        if hasPass {
                            self.presentingManagePassSheet = true
                        } else {
                            self.presentingPassSheet = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "plus.square")
                            
                            if hasPass {
                                Text("Eye Ease+")
                            } else {
                                Text("Upgrate to Plus")
                            }
                            
                            Spacer()
                            if hasPass {
                                Text("\(passStatus.description) plan")
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                    .foregroundStyle(hasPass ? Color.primary : Color.teal)
                    
                    RestorePurchasesButton()
                }
                
                Section {
                    Group {
                        LabeledContent {
                            Group {
                                if notificationAllowed {
                                    Text("Allowed")
                                        .foregroundStyle(Color.secondary)
                                } else {
                                    Button(action: {
                                        guard
                                            let appSettings = URL(string: UIApplication.openNotificationSettingsURLString), UIApplication.shared.canOpenURL(appSettings)
                                        else {
                                            return
                                        }
                                        
                                        UIApplication.shared.open(appSettings, options: [:])
                                    }, label: {
                                        Text("Open Settings")
                                    })
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                    .foregroundStyle(Color.teal)
                                    
                                }
                            }
                            
                        } label: {
                            HStack {
                                Image(systemName: "app.badge")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.red, .primary)
                                    .symbolEffect(.pulse, isActive: !notificationAllowed)
                                Text("Push notifications")
                            }
                        }
                        
                        Picker(selection: $reminderDays) {
                            ForEach(ReminderDays.allCases) { day in
                                Text(day.description)
                                    .tag(day)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "bell")
                                Text("Reminder")
                            }
                        }
                    }
                    .availableOnPlus()
                } header: {
                    HStack {
                        Text("Notification")
                        Spacer()
                        
                        if !hasPass {
                            GetPlusButton(didTap: $presentingPassSheet)
                        }
                    }
                } footer: {
                    Text("Set reminder days before lens replacement. Available on Plus")
                }
                
                Section("Application") {
                    Picker(selection: $appAppearance) {
                        ForEach(AppAppearance.allCases) { mode in
                            Text(mode.description).tag(mode)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "moon")
                            Text("Appearance")
                        }
                    }
                    
                }
                
                if
                    let privacyURL = URL(string: "https://www.freeprivacypolicy.com/live/6ae64009-85b9-4a23-92b0-85ef9d702474"),
                    let writeUsURL = URL(string: "mailto:altore.alisher@gmail.com") {
                    Section(header: Text("About")) {
                        Group {
                            Link(destination: writeUsURL) {
                                HStack {
                                    Image(systemName: "square.and.pencil")
                                    Text("Write us")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                            }
                            
                            Link(destination: privacyURL) {
                                HStack {
                                    Image(systemName: "hand.raised")
                                    Text("Privacy Policy")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                            }
                            
                            Button {
                                self.requestReview()
                            } label: {
                                HStack {
                                    Image(systemName: "star")
                                    Text("Review the app")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                            }
                            
                            HStack {
                                Image(systemName: "info.circle")
                                Text("Eye Ease - Lenses Tracker")
                                Spacer()
                                Text("v\(AppVersionProvider.appVersion())")
                                    .foregroundStyle(Color(.systemGray2))
                            }
                            
                            
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.teal)
                        .onTapGesture {
                            self.dismiss()
                        }
                }
            })
            .onChange(of: reminderDays, { oldValue, newValue in
                Task {
                    await NotificationManager.shared.reloadLocalNotificationByItems(true)
                }
            })
            .sheet(isPresented: $presentingPassSheet, content: {
                SubscriptionShopView()
            })
            .manageSubscriptionsSheet(isPresented: $presentingManagePassSheet, subscriptionGroupID: passGroupID)
            .tint(Color.teal)
            .navigationTitle("Settings")
            .toolbarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SettingsView()
}
