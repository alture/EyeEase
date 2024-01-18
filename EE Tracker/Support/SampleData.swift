//
//  SampleData.swift
//  EE Tracker
//
//  Created by Alisher on 10.12.2023.
//

import Foundation

struct SampleData {
    static var content: [LensItem] =
    [
        LensItem(name: "Secon Lense Yota 2", startDate: Date(), sphere: Sphere(left: -4.5, right: -4.25), isPinned: true, detail: LensDetail(baseCurve: "8.6", dia: "13", cylinder: "2.75", axis: "90")),
        LensItem(name: "Secon Lense Yota 3", startDate: Date(), sphere: Sphere(), isPinned: false, detail: LensDetail()),
        LensItem(name: "Secon Lense", startDate: Date(), sphere: Sphere(), isPinned: false, detail: LensDetail())
//        LensItem(
//            name: "Secon Lense Yota 2",
//            wearDuration: .daily,
//            startDate: Date(),
//            totalNumber: 30,
//            usedNumber: 28,
//            resolvedColor: ColorComponents.fromColor(.clear),
//            diopter: 5.0
//        ),
//        LensItem(
//            name: "My Lense Aqueue",
//            startDate: Date(),
//            totalNumber: 0,
//            usedNumber: 0,
//            resolvedColor: ColorComponents.fromColor(.clear),
//            diopter: -4.5,
//            isPinned: true
//        ),
//        LensItem(
//            name: "Secon Lense Yota",
//            wearDuration: .daily,
//            startDate: Date(),
//            totalNumber: 30,
//            usedNumber: 0,
//            resolvedColor: ColorComponents.fromColor(.clear),
//            diopter: 5.0
//        ),
//        LensItem(
//            name: "Lens Item Name 3",
//            wearDuration: .monthly,
//            startDate: Date(),
//            resolvedColor: ColorComponents.fromColor(.clear),
//            diopter: -4.5
//        ),
//        LensItem(
//            name: "Lens Item Name 4",
//            wearDuration: .biweekly,
//            startDate: Date(),
//            resolvedColor: ColorComponents.fromColor(.clear),
//            diopter: -4.5
//        ),

    ]
}
