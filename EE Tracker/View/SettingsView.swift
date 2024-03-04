//
//  SettingsView.swift
//  EE Tracker
//
//  Created by Alisher on 04.12.2023.
//

import SwiftUI

enum ReminderDays: Int, Identifiable, CustomStringConvertible, CaseIterable {
    case one = 1
    case three = 3
    case five = 5
    case seven = 7
    
    var description: String {
        switch self {
        case .one:
            return "\(self.rawValue) day"
        default:
            return "\(self.rawValue) days"
        }
    }
    
    var id: Self {
        return self
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable private var notificationManager = NotificationManager()
    @State private var pushNotificationAllowed: Bool = false
    @AppStorage("reminderDays") var reminderDays: ReminderDays = .three
    
    var body: some View {
        NavigationStack {
            if !pushNotificationAllowed {
                GroupBox(label:
                    Label("Enable push notifications", systemImage: "info.circle.fill")
                ) {
                    Text("Push notifications are currently disabled. Enable them below to receive timely reminders for changing your contact lenses. Stay on track with your eye care!")
                        .font(.footnote)
                        .padding(.top, 4.0)
                }
                .backgroundStyle(Color.yellow.opacity(0.7))
                .padding(.horizontal)
            }
            
            Form {
                Section(
                    header: Text("Application"),
                    footer: Text("Choose the number of days before the lens replacement reminder")
                ) {
                    LabeledContent {
                        Group {
                            if pushNotificationAllowed {
                                Text("Enabled")
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
                
                Section(header: Text("Account")) {
                    Button {
                        // Restore Purchases
                    } label: {
                        HStack {
                            Image(systemName: "gobackward")
                            Text("Resfore from iCloud")
                        }
                    }
                    .foregroundStyle(.primary)
                }
                
                
                if
                    let termOfURL = URL(string: "mailto:jon.doe@mail.com"),
                    let writeUsURL = URL(string: "mailto:jon.doe@mail.com") {
                    Section(header: Text("About")) {
                        Group {
                            Link(destination: writeUsURL) {
                                HStack {
                                    Image(systemName: "square.and.pencil")
                                    Text("Write us")
                                }
                            }
                            
                            Link(destination: termOfURL) {
                                HStack {
                                    Image(systemName: "doc.text")
                                    Text("Term of use")
                                }
                            }
                            
                            HStack {
                                Image(systemName: "info.circle")
                                Text("EyeEase - Lenses Tracker")
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
            .navigationTitle("Settings")
            .toolbarTitleDisplayMode(.inline)
            .onAppear {
                self.notificationManager.reloadAuthorizationSatus()
            }
            .onChange(of: notificationManager.authorizationStatus, { oldValue, newValue in
                switch newValue {
                case .notDetermined:
                    self.pushNotificationAllowed = false
                case .authorized:
                    self.pushNotificationAllowed = true
                default:
                    break
                }
            })
        }
    }
}

#Preview {
    SettingsView()
}
