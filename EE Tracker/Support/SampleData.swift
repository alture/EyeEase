//
//  SampleData.swift
//  EE Tracker
//
//  Created by Alisher on 10.12.2023.
//

import Foundation

struct SampleData {
    static var content: [LensItem] = [
        LensItem(
            name: "Lens Item Name",
            startDate: Date(),
            totalNumber: 0,
            usedNumber: 0,
            resolvedColor: ColorComponents.fromColor(.clear),
            diopter: -4.5
        ),
        LensItem(
            name: "Lens Item Name 2",
            wearDuration: .daily,
            startDate: Date(),
            totalNumber: 30,
            usedNumber: 0,
            resolvedColor: ColorComponents.fromColor(.clear),
            diopter: -4.5
        ),
        LensItem(
            name: "Lens Item Name 3",
            wearDuration: .daily,
            startDate: Date(),
            totalNumber: 30,
            usedNumber: 30,
            resolvedColor: ColorComponents.fromColor(.clear),
            diopter: -4.5
        ),
        LensItem(
            name: "Lens Item Name 4",
            wearDuration: .daily,
            startDate: Date(),
            totalNumber: 30,
            usedNumber: 10,
            resolvedColor: ColorComponents.fromColor(.clear),
            diopter: -4.5
        ),

    ]
}
