//
//  SettingsView.swift
//  EE Tracker
//
//  Created by Alisher on 04.12.2023.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var viewModel: SettingsViewModel = SettingsViewModel(
        plan: .free,
        pushNotificationAllowed: false,
        reminderDays: 3
    )
    
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Account")) {
                    if viewModel.plan == .free {
                        Button {
                            
                        } label: {
                            HStack {
                                Image(systemName: "plus.square")
                                Text("Upgrate to Pro")
                            }
                        }
                        .foregroundStyle(Color.teal)
                        
                    } else {
                        HStack {
                            Image(systemName: "plus.square")
                            Text("Subscription")
                            Spacer()
                            Text("Pro plan")
                        }
                    }
                    
                    Button {
                        // Restore Purchases
                    } label: {
                        HStack {
                            Image(systemName: "gobackward")
                            Text("Restore Purchases")
                        }
                    }
                    .foregroundStyle(.black)
                }
                
                Section(
                    header: Text("Application"),
                    footer: Text("Choose the number of days before the lens replacement reminder")
                ) {
                    Toggle(isOn: $viewModel.pushNotificationAllowed, label: {
                        HStack {
                            Image(systemName: "app.badge")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.red, .black)
                            Text("Push notification")
                        }
                    })
                    
                    Picker(selection: $viewModel.reminderDays) {
                        ForEach([1, 3, 5, 7], id: \.self) { day in
                            Text("\(day) \(day == 1 ? "day" : "days")")
                        }
                    } label: {
                        HStack {
                            Image(systemName: "bell")
                            Text("Reminder")
                        }
                    }
                    
                }
                
                Section(header: Text("About")) {
                    Group {
                        Button {
                            
                        } label: {
                            HStack {
                                Image(systemName: "square.and.pencil")
                                Text("Write us")
                            }
                        }
                        
                        Button {
                            
                        } label: {
                            HStack {
                                Image(systemName: "doc.text")
                                Text("Term of use")
                            }
                        }
                        
                        HStack {
                            Image(systemName: "info.circle")
                            Text("EyeEase - Lenses Tracker")
                            Spacer()
                            Text("v1.0")
                                .foregroundStyle(Color(.systemGray2))
                        }
                    }
                    .foregroundStyle(Color.black)
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
        }
    }
}

#Preview {
    SettingsView()
}
