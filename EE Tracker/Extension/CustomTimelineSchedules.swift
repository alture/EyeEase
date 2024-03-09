//
//  CustomTimelineSchedules.swift
//  EE Tracker
//
//  Created by Alisher Altore on 07.03.2024.
//

import Foundation
import SwiftUI

final class DailySchedule: TimelineSchedule {
    typealias Entries = [Date]
    
    func entries(from startDate: Date, mode: Mode) -> [Date] {
        (1...30).map { startDate.addingTimeInterval(Double($0 * 24 * 3600)) }
    }
}

final class HourlySchedule: TimelineSchedule {
    typealias Entries = [Date]
    
    func entries(from startDate: Date, mode: Mode) -> [Date] {
        (1...24).map { startDate.addingTimeInterval(Double($0 * 3600)) }
    }
}

extension TimelineSchedule where Self == DailySchedule {
    static var daily: Self { .init() }
}

extension TimelineSchedule where Self == HourlySchedule {
    static var hourly: Self { .init() }
}

