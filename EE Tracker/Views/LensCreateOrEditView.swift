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
                Picker("Eye Side", selection: $lensItem.specs.eyeSide) {
                    ForEach(EyeSide.allCases) { side in
                        Text(side.rawValue)
                    }
                }
                HStack {
                    Text("Diopter")
                    Spacer()
                    TextField("-2.5", value: $lensItem.specs.diopter, format: .number)
                        .fixedSize()
                }
                
                Picker("Wear duration", selection: $lensItem.specs.wearDuration) {
                    ForEach(LensWearDuration.allCases) { duration in
                        Text(duration.rawValue)
                    }
                }
                
                if lensItem.specs.wearDuration == .daily {
                    HStack {
                        Text("Quantity")
                        Spacer()
                        TextField("30", value: $lensItem.specs.currentQuantity, format: .number)
                            .fixedSize()
                    }
                }
                
                DatePicker("Start Date", selection: $lensItem.specs.startDate, displayedComponents: [.date])
                
            }
            
            Section(header: Text("Other")) {
                ColorPicker("Color", selection: $lensItem.specs.color)
                
                HStack {
                    Text("Cylinder")
                    Spacer()
                    TextField("Optional", value: $lensItem.specs.cylinder, format: .number)
                        .fixedSize()
                }
                
                HStack {
                    Text("Axis")
                    Spacer()
                    TextField("Optional", value: $lensItem.specs.axis, format: .number)
                        .fixedSize()
                }
            }
        }
    }
}

#Preview {
    LensCreateOrEditView(lensItem: LensItem(name: "Preview Name", specs: .default))
}
