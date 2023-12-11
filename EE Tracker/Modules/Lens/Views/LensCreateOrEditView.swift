//
//  LensCreateOrEditView.swift
//  EE Tracker
//
//  Created by Alisher on 07.12.2023.
//

import SwiftUI

struct LensCreateOrEditView: View {
    @EnvironmentObject var lensItem: LensItem
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    var body: some View {
        Form {
            Section(header: Text("Main")) {
                TextField("Name", text: $lensItem.name)
                    .autocorrectionDisabled(true)
                Picker("Eye Side", selection: $lensItem.eyeSide) {
                    ForEach(EyeSide.allCases) { side in
                        Text(side.rawValue)
                    }
                }
                HStack {
                    Text("Diopter")
                    Spacer()
                    TextField("-2.5", value: $lensItem.diopter, formatter: formatter)
                        .autocorrectionDisabled(true)
                        .textContentType(.telephoneNumber)
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
                        Text("Number of lens")
                        Spacer()
                        TextField("30", value: $lensItem.totalNumber, formatter: formatter)
                            .autocorrectionDisabled()
                            .textContentType(.telephoneNumber)
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
                    TextField("Optional", value: $lensItem.cylinder, format: .number)
                        .autocorrectionDisabled(true)
                        .textContentType(.telephoneNumber)
                        .multilineTextAlignment(.trailing)
                        .fixedSize()
                }
                
                HStack {
                    Text("Axis")
                    Spacer()
                    TextField("Optional", value: $lensItem.axis, formatter: formatter)
                        .multilineTextAlignment(.trailing)
                        .fixedSize()
                }
            }
        }
    }
}

#Preview {
    LensCreateOrEditView()
    .environmentObject(LensItem(
        name: "Preview Name",
        eyeSide: .paired,
        startDate: Date(),
        totalNumber: 0,
        usedNumber: 0,
        resolvedColor: .fromColor(.red),
        diopter: 0)
    )
}
