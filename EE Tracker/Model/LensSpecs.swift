//
//  LensSpecs.swift
//  EE Tracker
//
//  Created by Alisher on 05.12.2023.
//

import Foundation
import SwiftUI

enum EyeSide: String {
    case left = "Left"
    case right = "Right"
    case paired = "Paired"
}

enum LensWearDuration: String, CaseIterable, Identifiable {
    case daily = "Daily"
    case biweekly = "Bi-weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case halfYearly = "Half-yearly"
    case yearly = "Yearly"
    
    var limit: Int {
        switch self {
        case .daily:
            return 1
        case .biweekly:
            return 14
        case .monthly:
            return 30
        case .quarterly:
            return 90
        case .halfYearly:
            return 180
        case .yearly:
            return 360
        }
    }
    
    var id: Self { self }
}

struct LensSpecs {
    var eyeSide: EyeSide
    var wearDuration: LensWearDuration
    var startDate: Date
    var remainingDays: Int {
        guard let finishDate else { return 0 }
        let currentDate = Date()
        let daysElapsed = Calendar.current.dateComponents([.day], from: currentDate, to: finishDate)
        return daysElapsed.day ?? 0
    }
    var finishDate: Date? {
        Calendar.current.date(byAdding: .day, value: wearDuration.limit, to: startDate)
    }
    var fullQuantity: Int
    var currentQuantity: Int
    var color: Color
    var diopter: CGFloat
    var hasAstigmatism: Bool
    var cylinder: CGFloat?
    var axis: Int?
    
    static var `default` = LensSpecs(
        eyeSide: .paired,
        wearDuration: .monthly,
        startDate: Date(),
        fullQuantity: 30,
        currentQuantity: 12,
        color: .red,
        diopter: -4.5,
        hasAstigmatism: false,
        cylinder: nil,
        axis: nil
    )
}
