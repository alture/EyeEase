//
//  LensSpecs.swift
//  EE Tracker
//
//  Created by Alisher on 05.12.2023.
//

import Foundation
import SwiftUI

enum EyeSide: String, CaseIterable, Identifiable {
    case left = "Left"
    case right = "Right"
    case paired = "Paired"
    
    var id: Self { self }
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

final class LensSpecs: ObservableObject {
    @Published var eyeSide: EyeSide
    @Published var wearDuration: LensWearDuration
    @Published var startDate: Date
    var remainingDays: Int {
        guard let finishDate else { return 0 }
        let currentDate = Date()
        let daysElapsed = Calendar.current.dateComponents([.day], from: currentDate, to: finishDate)
        return daysElapsed.day ?? 0
    }
    var finishDate: Date? {
        Calendar.current.date(byAdding: .day, value: wearDuration.limit, to: startDate)
    }
    @Published var fullQuantity: Int?
    @Published var currentQuantity: Int?
    @Published var color: Color
    @Published var diopter: Float
    @Published var cylinder: Float?
    @Published var axis: Int?
    
    static var `default` = LensSpecs(
        eyeSide: .paired,
        wearDuration: .monthly,
        startDate: Date(),
        fullQuantity: nil,
        currentQuantity: nil,
        color: .clear,
        diopter: -4.5,
        cylinder: nil,
        axis: nil
    )
    
    init(eyeSide: EyeSide, wearDuration: LensWearDuration, startDate: Date, fullQuantity: Int? = nil, currentQuantity: Int? = nil, color: Color, diopter: Float, cylinder: Float? = nil, axis: Int? = nil) {
        self.eyeSide = eyeSide
        self.wearDuration = wearDuration
        self.startDate = startDate
        self.fullQuantity = fullQuantity
        self.currentQuantity = currentQuantity
        self.color = color
        self.diopter = diopter
        self.cylinder = cylinder
        self.axis = axis
    }
}
