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
        LensItem(
            name: "My Lense Aqueue",
            startDate: Date(),
            totalNumber: 0,
            usedNumber: 0,
            resolvedColor: ColorComponents.fromColor(.clear),
            diopter: -4.5,
            isPinned: true
        ),
        LensItem(
            name: "Secon Lense Yota",
            wearDuration: .daily,
            startDate: Date(),
            totalNumber: 30,
            usedNumber: 0,
            resolvedColor: ColorComponents.fromColor(.clear),
            diopter: 5.0
        ),
        LensItem(
            name: "Lens Item Name 3",
            wearDuration: .monthly,
            startDate: Date(),
            resolvedColor: ColorComponents.fromColor(.clear),
            diopter: -4.5
        ),
        LensItem(
            name: "Lens Item Name 4",
            wearDuration: .biweekly,
            startDate: Date(),
            resolvedColor: ColorComponents.fromColor(.clear),
            diopter: -4.5
        ),

    ]
}
