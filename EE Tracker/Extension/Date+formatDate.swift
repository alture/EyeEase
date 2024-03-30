//
//  Date+formatDate.swift
//  EE Tracker
//
//  Created by Alisher Altore on 06.03.2024.
//

import SwiftUI

extension Date {
    func formattedDate(with format: String = "EEEE, MMM d") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func relativeFormattedDate(with format: String = "EEEE, MMM d") -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(self) {
            return String(localized: "Today")
        } else if calendar.isDateInYesterday(self) {
            return String(localized: "Yesterday")
        } else if calendar.isDateInTomorrow(self) {
            return String(localized: "Tomorrow")
        } else {
            return self.formattedDate(with: format)
        }
    }
    
    var startOfDay: Self {
        Calendar.current.startOfDay(for: self)
    }
}
