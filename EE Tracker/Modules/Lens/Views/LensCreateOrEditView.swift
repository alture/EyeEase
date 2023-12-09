//
//  LensCreateOrEditView.swift
//  EE Tracker
//
//  Created by Alisher on 07.12.2023.
//

import SwiftUI

struct LensCreateOrEditView: View {
    @ObservedObject var lensItem: LensItem
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
                    TextField("-2.5", value: $lensItem.diopter, format: .number)
                        .fixedSize()
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
                        TextField("30", value: $lensItem.totalNumber, format: .number)
                            .fixedSize()
                    }
                    
                    HStack {
                        Text("Used number of lens")
                        Spacer()
                        TextField("0", value: $lensItem.currentNumber, format: .number)
                            .fixedSize()
                    }
                }
                
                DatePicker("Start Date", selection: $lensItem.startDate, displayedComponents: [.date])
                
            }
            
            Section(header: Text("Other")) {
//                ColorPicker("Color", selection: $lensItem.color)
                
                HStack {
                    Text("Cylinder")
                    Spacer()
                    TextField("Optional", value: $lensItem.cylinder, format: .number)
                        .fixedSize()
                }
                
                HStack {
                    Text("Axis")
                    Spacer()
                    TextField("Optional", value: $lensItem.axis, format: .number)
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
        currentNumber: 0,
        resolvedColor: .fromColor(.red),
        diopter: 0)
    )
}
