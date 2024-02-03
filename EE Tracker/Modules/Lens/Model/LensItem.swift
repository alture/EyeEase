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
final class LensItem: ObservableObject {
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
    var startDate: Date {
        didSet {
            self.changeDate = Calendar.current.date(byAdding: .day, value: wearDuration.limit, to: startDate) ?? Date.now
        }
    }
    var changeDate: Date
    var totalNumber: Int?
    var usedNumber: Int
    var sphere: Sphere
    var detail: LensDetail
    var isWearing: Bool
    var isSelected: Bool 
    
    init(
        id: UUID = UUID(),
        name: String = "",
        eyeSide: EyeSide = .both,
        wearDuration: WearDuration = .monthly,
        startDate: Date = Date.now,
        totalNumber: Int? = nil,
        usedNumber: Int = 0,
        sphere: Sphere = Sphere(),
        isWearing: Bool = true,
        detail: LensDetail = LensDetail(),
        isSelected: Bool = false
    ) {
        self.id = id
        self.name = name
        self.eyeSide = eyeSide
        self.wearDuration = wearDuration
        self.startDate = startDate
        self.totalNumber = totalNumber
        self.usedNumber = usedNumber
        self.sphere = sphere
        self.isWearing = isWearing
        self.detail = detail
        self.isSelected = isSelected
        self.changeDate = Calendar.current.date(byAdding: .day, value: wearDuration.limit, to: startDate) ?? Date.now
    }
}

// MARK: - Identifiable, Hashable
extension LensItem: Identifiable, Hashable {
    static func == (lhs: LensItem, rhs: LensItem) -> Bool {
        return lhs.id == rhs.id && lhs.isWearing == rhs.isWearing
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Getters
extension LensItem {
    var isExpired: Bool {
        switch wearDuration {
        case .daily:
            guard let totalNumber else { return false }
            return totalNumber <= usedNumber
        default:
            return remainingDays <= 0
        }
    }
    
    var isFilled: Bool {
        let nameIsFilled = !name.isEmpty
        switch wearDuration {
        case .daily:
            return totalNumber != nil && nameIsFilled
        default:
            return nameIsFilled
        }
    }
    
    var limitDesciption: String {
        switch wearDuration {
        case .daily:
            return "\(usedNumber) lens used"
        default:
            return "\(remainingDays) \(remainingDays > 1 ? "days" : "day") left"
        }
    }
    
    var sphereDescription: String {
        switch eyeSide {
        case .left:
            return "L: \(sphere.left)"
        case .right:
            return "R: \(sphere.left)"
        case .both:
            if sphere.isSame {
                return "\(sphere.left)"
            } else {
                return "\(sphere.left); \(sphere.right)"
            }
        }
    }
    
    var progressColor: Color {
//        var progress: Int = remainingDays
//        switch wearDuration {
//        case .daily:
//            guard let totalNumber else { return Color.clear }
//            progress = totalNumber - usedNumber
//        default:
//            break
//        }
        
        switch usedPeriod {
        case .new:
            return Color.green
        case .used:
            return Color.yellow
        case .readyToExpire:
            return Color.red
        }
    }
    
    var usedPeriod: UsedPeriod {
        switch remainingDays  {
        case 0...2:
            return .readyToExpire
        case 3...6:
            return .used
        default:
            return .new
        }
    }
    
    var remainingDays: Int {
        guard let finishDate else { return 0 }
        let currentDate = Date()
        let daysElapsed = Calendar.current.dateComponents([.day], from: currentDate, to: finishDate)
        return max(0, daysElapsed.day ?? 0)
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
}

// MARK: - Actions
extension LensItem {
    func increaseQuantity(for lense: LensItem) {
        let maxValue = lense.totalNumber ?? 0
        let quantity = min(maxValue, lense.usedNumber + (eyeSide == .both ? 2 : 1))
        lense.usedNumber = quantity
        objectWillChange.send()
    }
    
    func decreaseQuantity(for lense: LensItem) {
        let quantity = max(0, lense.usedNumber - (eyeSide == .both ? 2 : 1))
        lense.usedNumber = quantity
        objectWillChange.send()
    }
    
    func restart() {
        startDate = Date()
        usedNumber = 0
    }
    
}

struct Sphere: Codable {
    var left: Float
    var right: Float
    
    var isSame: Bool { left == right }
    var proportional: Bool
    
    init(left: Float = 0, right: Float = 0, proportional: Bool = true) {
        self.left = left
        self.right = right
        self.proportional = proportional
    }
}

struct LensDetail: Codable {
    var baseCurve: String
    var dia: String
    var cylinder: String
    var axis: String
    
    var hasAnyValue: Bool {
        baseCurve != "" || dia != "" || cylinder != "" || axis != ""
    }
    
    init(baseCurve: String = "", dia: String = "", cylinder: String = "", axis: String = "") {
        self.baseCurve = baseCurve
        self.dia = dia
        self.cylinder = cylinder
        self.axis = axis
    }
}

enum UsedPeriod {
    case new
    case used
    case readyToExpire
}
