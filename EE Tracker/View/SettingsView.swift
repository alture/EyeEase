//
//  SettingsView.swift
//  EE Tracker
//
//  Created by Alisher on 04.12.2023.
//

import SwiftUI
import StoreKit
import TipKit

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
    @Environment(\.openURL) private var openURL
    
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
    @AppStorage(AppStorageKeys.repeatReminder) var repeatReminder: Bool = false
    var notificationWarningTip = NotificationWarningTip()
    
    var body: some View {
        NavigationStack {
            Form {
                TipView(notificationWarningTip) { action in
                    guard
                        action.id == "open-settings",
                        let url = URL(string: UIApplication.openNotificationSettingsURLString)
                    else {
                        return
                    }
                    
                    openURL(url)
                }
                
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
                                            let url = URL(string: UIApplication.openNotificationSettingsURLString)
                                        else {
                                            return
                                        }
                                        
                                        openURL(url)
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
                                Text("Push Notifications")
                            }
                        }
                        
                        Toggle(isOn: $repeatReminder) {
                            HStack {
                                Image(systemName: "bell")
                                Text("Repeats")
                            }
                        }
                        .disabled(!notificationAllowed)
                        
                        Picker(selection: $reminderDays) {
                            ForEach(ReminderDays.allCases) { day in
                                Text(day.description)
                                    .tag(day)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "calendar")
                                Text("Early Reminder")
                            }
                        }
                        .disabled(!notificationAllowed)
                        
                    }
                    .availableOnPlus()
                } header: {
                    HStack {
                        Text("Notification")
                        Spacer()
                        
                        if !hasPass {
                            Button("Available on Plus", systemImage: "crown.fill") {
                                self.presentingPassSheet = true
                            }
                            .buttonStyle(.availableOnPlus)
                        }
                    }
                } footer: {
                    Text("Set reminder day before contact lens replacement. Available on Plus")
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
                
                Section(header: Text("About")) {
                    Group {
                        Link(destination: AppConstants.URLs.supportMail) {
                            HStack {
                                Image(systemName: "square.and.pencil")
                                Text("Write us")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                        
                        Link(destination: AppConstants.URLs.privacyPolicy) {
                            HStack {
                                Image(systemName: "hand.raised")
                                Text("Privacy Policy")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                        
                        Link(destination: AppConstants.URLs.termsOfUse) {
                            HStack {
                                Image(systemName: "doc.text")
                                Text("Terms of Use")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                        
                        Button {
                            self.requestReviewManually()
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
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        self.dismiss()
                    } label: {
                        Text("Close")
                    }
                    .foregroundStyle(Color.teal)

                }
            })
            .onChange(of: reminderDays, { oldValue, newValue in
                Task {
                    await NotificationManager.shared.reloadLocalNotificationByItems(true)
                }
            })
            .onChange(of: repeatReminder, { oldValue, newValue in
                Task {
                    await NotificationManager.shared.reloadLocalNotificationByItems(true)
                }
            })
            .onChange(of: hasPass, { oldValue, newValue in
                print("SettingsView hasPass: \(newValue)")
                NotificationWarningTip.hasPass = hasPass
            })
            .onChange(of: notificationAllowed, { oldValue, newValue in
                print("SettingsView Notification Allowed: \(notificationAllowed)")
                NotificationWarningTip.notificationAllowed = newValue
            })
            .onAppear {
                NotificationWarningTip.hasPass = hasPass
                NotificationWarningTip.notificationAllowed = notificationAllowed
            }
            .sheet(isPresented: $presentingPassSheet, content: {
                SubscriptionShopView()
            })
            .manageSubscriptionsSheet(isPresented: $presentingManagePassSheet, subscriptionGroupID: passGroupID)
            .tint(Color.teal)
            .navigationTitle("Settings")
            .toolbarTitleDisplayMode(.inline)
        }
    }
    
    private func requestReviewManually() {
        
        guard let writeReviewURL = AppConstants.URLs.applicationReview else {
            print("Expeceted a valid URL")
            return
        }
        
        openURL(writeReviewURL)
    }
}

#Preview {
    SettingsView()
        .environment(\.passStatus, .monthly)
        .environment(\.notificationGranted, true)
}
