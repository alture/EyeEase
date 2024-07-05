//
//  Collection+groupedByMonth.swift
//  EE Tracker
//
//  Created by Alisher Altore on 08.05.2024.
//

import Foundation

protocol DateRepresentable {
    var startDate: Date { get set }
}

extension Collection where Element: DateRepresentable {
    func groupedBy(_ components: Set<Calendar.Component>) -> [Date: [Element]] {
        let calendar = Calendar.current
        return Dictionary(grouping: self) { element in
            let dateComponents = calendar.dateComponents(components, from: element.startDate)
            return calendar.date(from: dateComponents)!
        }
    }
}
