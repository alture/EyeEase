//
//  LensCreateOrEditView.swift
//  EE Tracker
//
//  Created by Alisher on 07.12.2023.
//

import SwiftUI

struct LensCreateOrEditView: View {
    @ObservedObject var lensItem: LensItem
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    var body: some View {
        Form {
            Section(header: Text("Main")) {
                TextField("Name", text: $lensItem.name)
                Picker("Eye Side", selection: $lensItem.eyeSide) {
                    ForEach(EyeSide.allCases) { side in
                        Text(side.rawValue)
                    }
                }
                HStack {
                    Text("Diopter")
                    Spacer()
                    TextField("-2.5", value: $lensItem.diopter, formatter: formatter)
                        .frame(minWidth: 60)
                        .multilineTextAlignment(.trailing)
                }
                
                Picker("Wear duration", selection: $lensItem.wearDuration) {
                    ForEach(WearDuration.allCases) { duration in
                        Text(duration.rawValue)
                    }
                }
                
                if lensItem.wearDuration == .daily {
                    HStack {
                        Text("Total number of lens")
                        Spacer()
                        TextField("30", value: $lensItem.totalNumber, formatter: formatter)
                            .frame(minWidth: 60)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                DatePicker("Start Date", selection: $lensItem.startDate, displayedComponents: [.date])
                
            }
            
            Section(header: Text("Other")) {
//                ColorPicker("Color", selection: $lensItem.color)
                
                HStack {
                    Text("Cylinder")
                    Spacer()
                    TextField("Optional", value: $lensItem.cylinder, formatter: formatter)
                        .fixedSize()
                }
                
                HStack {
                    Text("Axis")
                    Spacer()
                    TextField("Optional", value: $lensItem.axis, formatter: formatter)
                        .fixedSize()
                }
            }
        }
    }
}

#Preview {
    LensCreateOrEditView(lensItem: LensItem(
        name: "Preview Name",
        eyeSide: .paired,
        startDate: Date(),
        totalNumber: 0,
        usedNumber: 0,
        resolvedColor: .fromColor(.red),
        diopter: 0)
    )
}
