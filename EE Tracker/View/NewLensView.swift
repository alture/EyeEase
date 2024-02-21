//
//  NewLensView.swift
//  EE Tracker
//
//  Created by Alisher on 08.12.2023.
//

import SwiftUI
import UserNotifications

struct NewLensView: View {
    @State var draftLensItem: LensItem = LensItem(name: "My Lens", startDate: Date(), sphere: Sphere(), detail: LensDetail())
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    var body: some View {
        NavigationStack {
            LensFormView(lensItem: draftLensItem)
                .navigationTitle("Create Lens")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
//                    ToolbarItem(placement: .topBarLeading) {
//                        Button("Cancel") {
//                            self.dismiss()
//                        }
//                        .foregroundStyle(.teal)
//                    }
                    
                    if self.draftLensItem.isFilled {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Add") {
                                self.modelContext.insert(self.draftLensItem)
                                self.createNotification(by: self.draftLensItem)
                                self.dismiss()
                            }
                            .foregroundStyle(.teal)
                        }
                    }
                }
        }
        .accentColor(.teal)
    }
    
    private func createNotification(by item: LensItem) {
        let content = UNMutableNotificationContent()
        content.title = "EyeEase"
        content.body = "\(item.name) will expire today"
        content.sound = UNNotificationSound.default
        
        var dateComponent = DateComponents()
        dateComponent.day = item.remainingDays
        dateComponent.hour = 10
        
        print(dateComponent.description)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

#Preview {
    NavigationStack {
        NewLensView()
            .modelContainer(previewContainer)
    }
}
