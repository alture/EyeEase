//
//  Date+formatDate.swift
//  EE Tracker
//
//  Created by Alisher Altore on 06.03.2024.
//

import Foundation

extension Date {
    func formattedDate(with format: String = "EEEE, MMM d") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func relativeFormattedDate(with format: String = "EEEE, MMM d") -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(self) {
            return "Tomorrow"
        } else {
            let dateDifference = calendar.dateComponents([.day], from: Date.now.startOfDay, to: self)
            if let dayCount = dateDifference.day, dayCount <= 7 {
                if dayCount > 0 {
                    return "After \(dayCount) \(dayCount == 1 ? "day" : "days")"
                } else if dayCount < 0 {
                    return "\(abs(dayCount)) \(abs(dayCount) == 1 ? "day" : "days") ago"
                }
            }
            
            return formattedDate()
        }
    }
    
    var startOfDay: Self {
        Calendar.current.startOfDay(for: self)
    }
    
    var nextOfDay: Self {
        let calendar = Calendar.current
        
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: self) else {
            return self
        }
        
        return nextDay.startOfDay
    }
}
