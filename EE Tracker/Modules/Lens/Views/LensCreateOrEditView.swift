//
//  LensCreateOrEditView.swift
//  EE Tracker
//
//  Created by Alisher on 07.12.2023.
//

import SwiftUI

struct LensCreateOrEditView: View {
    @Binding var lensItem: LensItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Main")) {
                    TextField("Lens name", text: $lensItem.name)
                        .autocorrectionDisabled(true)
                    Picker("Wear duration", selection: $lensItem.wearDuration) {
                        ForEach(WearDuration.allCases) { duration in
                            Text(duration.rawValue)
                        }
                    }
                    
                    HStack {
                        Text("Diopter")
                        Spacer()
                        TextField("Required", value: $lensItem.diopter, format: .number)
                            .keyboardType(.numberPad)
                            .autocorrectionDisabled(true)
                            .frame(minWidth: 60)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Eye Side", selection: $lensItem.eyeSide) {
                        ForEach(EyeSide.allCases) { side in
                            Text(side.rawValue)
                        }
                    }
                    
                    if lensItem.wearDuration == .daily {
                        HStack {
                            Text("Number of lens")
                            Spacer()
                            TextField("Required", value: $lensItem.totalNumber, format: .number)
                                .keyboardType(.asciiCapableNumberPad)
                                .autocorrectionDisabled(true)
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
                            .keyboardType(.numberPad)
                            .autocorrectionDisabled(true)
                            .multilineTextAlignment(.trailing)
                            .fixedSize()
                    }
                    
                    HStack {
                        Text("Axis")
                        Spacer()
                        TextField("Optional", value: $lensItem.axis, format: .number)
                            .keyboardType(.numberPad)
                            .autocorrectionDisabled(true)
                            .multilineTextAlignment(.trailing)
                            .fixedSize()
                    }
                }
                
            }
        }
    }
}

#Preview {
    let lensItem = LensItem(
        name: "Preview Name",
        eyeSide: .paired,
        startDate: Date(),
        totalNumber: 0,
        usedNumber: 0,
        resolvedColor: .fromColor(.red),
        diopter: 0)
    return LensCreateOrEditView(lensItem: .constant(lensItem))
}
