//
//  SettingsView.swift
//  EE Tracker
//
//  Created by Alisher on 04.12.2023.
//

import SwiftUI
import StoreKit

enum ReminderDays: Int, Identifiable, CustomStringConvertible, CaseIterable {
    case one = 1
    case three = 3
    case five = 5
    case seven = 7
    
    var description: String {
        switch self {
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
    @Binding var passStatus: PassStatus
    @AppStorage(AppStorageKeys.appAppearance) var appAppearance: AppAppearance = .system
    
    @ObservedObject var notificationManager: NotificationManager
    @State private var pushNotificationAllowed: Bool = false
    @Binding var showingSubscription: Bool
    
    var isSubscribed: Bool = false
    
    var body: some View {
        NavigationStack {
            if !pushNotificationAllowed && !(passStatus == .notSubscribed) {
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
                        self.dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.showingSubscription.toggle()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "plus.square")
                            
                            Group {
                                if passStatus == .notSubscribed {
                                    Text("Upgrate to Plus")
                                } else {
                                    Text("Eye Ease+")
                                    Spacer()
                                    Text("\(passStatus.description) plan")
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                    }
                    .foregroundStyle(passStatus == .notSubscribed ? .teal : .primary)
                    
                    Button {
                        Task {
                            do {
                                try await AppStore.sync()
                            } catch {
                                print(error)
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "gobackward")
                            Text("Restore Purchases")
                        }
                    }
                    .foregroundStyle(Color.primary)
                }
                
                Section(
                    header: Text("Application"),
                    footer: Text("Set reminder days before lens replacement")
                ) {
                    LabeledContent {
                        Group {
                            if pushNotificationAllowed {
                                Text("Allowed")
                                    .foregroundStyle(.secondary)
                            } else {
                                Button(action: {
                                    self.notificationManager.openNotificationSettings()
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
                                .symbolEffect(.pulse, isActive: !pushNotificationAllowed)
                            Text("Push notifications")
                        }
                    }
                    
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
                    
                    Picker(selection: $notificationManager.reminderDays) {
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
            .tint(Color.teal)
            .navigationTitle("Settings")
            .toolbarTitleDisplayMode(.inline)
            .onAppear {
                self.notificationManager.reloadAuthorizationSatus()
                self.switchAuthorizationStatus(notificationManager.authorizationStatus)
            }
            .onChange(of: notificationManager.authorizationStatus, { oldValue, newValue in
                self.switchAuthorizationStatus(newValue)
            })
        }
    }
    
    private func switchAuthorizationStatus(_ authorizationStatus: UNAuthorizationStatus? = nil) {
        switch authorizationStatus {
        case .notDetermined:
            self.pushNotificationAllowed = false
        case .authorized, .provisional:
            self.pushNotificationAllowed = true
        default:
            break
        }
    }
}

#Preview {
    SettingsView(
        passStatus: .constant(.notSubscribed),
        notificationManager: NotificationManager(),
        showingSubscription: .constant(true)
    )
}
