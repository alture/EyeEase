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
    var id: UUID = UUID()
    var name: String = ""
    var eyeSide: EyeSide = EyeSide.both
    var wearDuration: WearDuration = WearDuration.biweekly
    var startDate: Date = Date.now
    var changeDate: Date = Date.distantPast
    var totalNumber: Int?
    var usedNumber: Int = 0
    @Relationship(deleteRule: .cascade, inverse: \Sphere.lensItem)
    var sphere: Sphere? = nil
    @Relationship(deleteRule: .cascade, inverse: \LensDetail.lensItem)
    var detail: LensDetail? = nil
    var isWearing: Bool = false
    
    init(
        id: UUID = UUID(),
        name: String = "",
        eyeSide: EyeSide = .both,
        wearDuration: WearDuration = .monthly,
        startDate: Date = Date.now.startOfDay,
        totalNumber: Int? = nil,
        usedNumber: Int = 0,
        sphere: Sphere? = nil,
        isWearing: Bool = false,
        detail: LensDetail? = nil
    ) {
        self.id = id
        self.name = name
        self.eyeSide = eyeSide
        self.wearDuration = wearDuration
        self.startDate = startDate
        self.changeDate = Calendar.current.date(byAdding: .day, value: wearDuration.limit, to: startDate) ?? Date.now
        self.totalNumber = totalNumber
        self.usedNumber = usedNumber
        self.sphere = sphere
        self.isWearing = isWearing
        self.detail = detail
    }
}

// MARK: - Identifiable, Hashable
extension LensItem: Identifiable, Hashable {
    static func == (lhs: LensItem, rhs: LensItem) -> Bool {
        return lhs.id == rhs.id 
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Actions
//extension LensItem {
//    func increaseQuantity(for lense: LensItem) {
//        let maxValue = lense.totalNumber ?? 0
//        let quantity = min(maxValue, lense.usedNumber + (eyeSide == .both ? 2 : 1))
//        lense.usedNumber = quantity
//        objectWillChange.send()
//    }
//    
//    func decreaseQuantity(for lense: LensItem) {
//        let quantity = max(0, lense.usedNumber - (eyeSide == .both ? 2 : 1))
//        lense.usedNumber = quantity
//        objectWillChange.send()
//    }
//}
