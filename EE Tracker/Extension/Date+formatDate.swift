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
}
