//
//  NotificationWarningTip.swift
//  EE Tracker
//
//  Created by Alisher Altore on 18.03.2024.
//

import TipKit

struct NotificationWarningTip: Tip {
    @Parameter
    static var hasPass: Bool = true
    
    @Parameter
    static var notificationAllowed: Bool = false
    
    var rules: [Rule] {
        [
            #Rule(Self.$hasPass) { $0 == true },
            #Rule(Self.$notificationAllowed) { $0 == false }
        ]
    }
    
    var title: Text {
        Text("Notifications are disabled")
            .fontDesign(.rounded)
    }
    
    var message: Text? {
        Text("Turn on push notifications to get reminders to replace your lenses. Stay on track with your eye care!")
    }
    
    var image: Image? {
        Image(systemName: "info.circle")
    }
    
    var actions: [Action] {
        Action(id: "open-settings", {
            Text("Turn on")
                .fontDesign(.rounded)
        })
    }
}
