//
//  LensItem.swift
//  EE Tracker
//
//  Created by Alisher on 03.12.2023.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class LensItem: Identifiable, Hashable, ObservableObject {
    static func == (lhs: LensItem, rhs: LensItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    @Attribute(.unique) var id: UUID
    var name: String {
        didSet {
            if name.count > 20 {
                name.removeLast()
            }
        }
    }
    var eyeSide: EyeSide
    var wearDuration: WearDuration
    var startDate: Date
    var changeDate: Date {
        let endDate = Calendar.current.date(byAdding: .day, value: wearDuration.limit, to: startDate)
        return endDate ?? Date()
    }
    var remainingDays: Int {
        guard let finishDate else { return 0 }
        let currentDate = Date()
        let daysElapsed = Calendar.current.dateComponents([.day], from: currentDate, to: finishDate)
        return daysElapsed.day ?? 0
    }
    var finishDate: Date? {
        Calendar.current.date(byAdding: .day, value: wearDuration.limit, to: startDate)
    }
    var progress: CGFloat {
        switch wearDuration {
        case .daily:
            return CGFloat(Double(usedNumber) / Double(totalNumber ?? 0))
        default:
            return CGFloat(1.0 - Double(remainingDays) / Double(wearDuration.limit))
        }
    }
    var totalNumber: Int?
    var usedNumber: Int
    var color: Color { resolvedColor.color }
    var resolvedColor: ColorComponents
    var diopter: Double?
    var cylinder: Float?
    var axis: Int?
    var isPinned: Bool
    
    var limitDesciption: String {
        switch wearDuration {
        case .daily:
            return "\(usedNumber) lens used"
        default:
            return "\(remainingDays) \(remainingDays > 1 ? "days" : "day") left"
        }
    }
    
    var progressColor: Color {
        var progress: Int = remainingDays
        switch wearDuration {
        case .daily:
            guard let totalNumber else { return Color.clear }
            progress = totalNumber - usedNumber
        default:
            break
        }
        switch progress  {
        case 0...2:
            return Color.red
        case 3...6:
            return Color.yellow
        default:
            return Color.green
        }
    }
    
    func increaseQuantity(for lense: LensItem) {
        let maxValue = lense.totalNumber ?? 0
        let quantity = min(maxValue, lense.usedNumber + (eyeSide == .paired ? 2 : 1))
        lense.usedNumber = quantity
        objectWillChange.send()
    }
    
    func decreaseQuantity(for lense: LensItem) {
        let quantity = max(0, lense.usedNumber - (eyeSide == .paired ? 2 : 1))
        lense.usedNumber = quantity
        objectWillChange.send()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func restart() {
        startDate = Date()
        usedNumber = 0
    }
    
    func isFilled() -> Bool {
        let nameIsFilled = !name.isEmpty
        let diopterIsFilled = diopter != 0
        switch wearDuration {
        case .daily:
            return totalNumber != nil && nameIsFilled && diopterIsFilled
        default:
            return nameIsFilled && diopterIsFilled
        }
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        eyeSide: EyeSide = .paired,
        wearDuration: WearDuration = .monthly,
        startDate: Date,
        totalNumber: Int? = nil,
        usedNumber: Int = 0,
        resolvedColor: ColorComponents,
        diopter: Double? = nil,
        cylinder: Float? = nil,
        axis: Int? = nil,
        isPinned: Bool = true) {
            self.id = id
            self.name = name
            self.eyeSide = eyeSide
            self.wearDuration = wearDuration
            self.startDate = startDate
            self.totalNumber = totalNumber
            self.usedNumber = usedNumber
            self.resolvedColor = resolvedColor
            self.diopter = diopter
            self.cylinder = cylinder
            self.axis = axis
            self.isPinned = isPinned
        }
}

struct ColorComponents: Codable {
    let red: Float
    let green: Float
    let blue: Float

    var color: Color {
        Color(red: Double(red), green: Double(green), blue: Double(blue))
    }

    static func fromColor(_ color: Color) -> ColorComponents {
        let resolved = color.resolve(in: EnvironmentValues())
        return ColorComponents(
            red: resolved.red,
            green: resolved.green,
            blue: resolved.blue
        )
    }
}

