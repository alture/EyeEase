//
//  SampleData.swift
//  EE Tracker
//
//  Created by Alisher on 10.12.2023.
//

import Foundation

struct SampleData {
    static var dateComponents: DateComponents {
        var dateComponents = DateComponents()
        dateComponents.setValue(-24, for: .day)
        return dateComponents
    }
    
    static var dateComponents2: DateComponents {
        var dateComponents = DateComponents()
        dateComponents.setValue(-28, for: .day)
        return dateComponents
    }
    static var content: [LensItem] =
    [
        LensItem(name: "Secon Lense Yota 2", wearDuration: .monthly, startDate: Date.now.startOfDay, sphere: Sphere(left: -4.5, right: -4.25, proportional: false), isWearing: false, detail: LensDetail(baseCurve: "8.6", dia: "13", cylinder: "-2.75", axis: "90")),
        LensItem(name: "Secon Lense Yota 3", wearDuration: .monthly, startDate: Calendar.current.date(byAdding: dateComponents, to: Date(), wrappingComponents: false) ?? Date.now, sphere: nil, isWearing: false, detail: nil),
        LensItem(name: "Secon Lense", wearDuration: .monthly, startDate: Calendar.current.date(byAdding: dateComponents2, to: Date(), wrappingComponents: false) ?? Date.now, sphere: Sphere(), isWearing: false, detail: LensDetail(baseCurve: "8,3", dia: "", cylinder: "-14.5", axis: "")),
        LensItem(name: "Secon Lense", wearDuration: .biweekly, startDate: Calendar.current.date(byAdding: dateComponents2, to: Date(), wrappingComponents: false) ?? Date.now, sphere: nil, isWearing: false, detail: LensDetail(baseCurve: "8,3", dia: "", cylinder: "-14.5", axis: ""))
    ]
}
