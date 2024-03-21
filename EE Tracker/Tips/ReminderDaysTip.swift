//
//  ReminderDaysTip.swift
//  EE Tracker
//
//  Created by Alisher Altore on 19.03.2024.
//

import TipKit

struct ReminderDaysTip: Tip {
    @Parameter
    static var hasPass: Bool = false
    
    var options: [TipOption] {
        MaxDisplayCount(1)
    }
    
    var rules: [Rule] {
        #Rule(Self.$hasPass) {
            $0 == true
        }
    }
    
    var title: Text {
        Text("Set early reminder")
    }
}
