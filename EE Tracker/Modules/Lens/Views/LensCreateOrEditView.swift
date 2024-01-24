//
//  LensCreateOrEditView.swift
//  EE Tracker
//
//  Created by Alisher on 07.12.2023.
//

import SwiftUI

struct LensCreateOrEditView: View {
    @Binding var lensItem: LensItem
    @FocusState private var focusField: FocusableField?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            MainSection(focusField: _focusField, lensItem: $lensItem)
            SphereSection(sphere: $lensItem.sphere)
            DetailSection(detail: $lensItem.detail, focusField: _focusField)
        }
        .toolbar {
            if focusField != .name {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button {
                            focusField = nil
                        } label: {
                            Text("Done")
                        }
                    }
                }
            }
        }
        .defaultFocus($focusField, .name)
    }
}

enum FocusableField:  Hashable {
    case name
    case bc
    case dia
    case cylinder
    case axis
    
    var unitDescription: String {
           switch self {
           case .name:
               return ""
           case .bc, .dia:
               return "mm"
           case .cylinder:
               return "D"
           case .axis:
               return "°"
           }
       }
}

struct PowerPicker: View {
    var diopterRange: [Float] = Array(stride(from: -12.0, through: 12.0, by: 0.25))
    @Binding var value: Float
    var body: some View {
        Picker("Power", selection: $value) {
            ForEach(diopterRange, id: \.self) { value in
                Text("\(value > 0 ? "+" : "")\(String(format: "%.2f", value))")
            }
        }
        .pickerStyle(WheelPickerStyle())
        .frame(height: 100)
        .padding(.all, -8)
    }
}

struct MainSection: View {
    @FocusState var focusField: FocusableField?
    @Binding var lensItem: LensItem
    var body: some View {
            Section {
                HStack {
                    Text("Lens Brand")
                    Spacer()
                    TextField("Required", text: $lensItem.name)
                        .autocorrectionDisabled(true)
                        .multilineTextAlignment(.trailing)
                        .focused($focusField, equals: .name)
                        .foregroundStyle(.teal)
                        .submitLabel(.done)
                        .fixedSize()
                }
                Picker("Usage Period", selection: $lensItem.wearDuration) {
                    ForEach(WearDuration.allCases.filter { $0 != .daily && $0 != .yearly }) { duration in
                        Text(duration.rawValue)
                    }
                }
                
                Picker("For Which Eye?", selection: $lensItem.eyeSide) {
                    ForEach(EyeSide.allCases) { side in
                        Text(side.rawValue)
                    }
                }
                
                if lensItem.wearDuration == .daily {
                    HStack {
                        Text("Quantity of Lenses")
                        Spacer()
                        TextField("Required", value: $lensItem.totalNumber, format: .number)
                            .keyboardType(.asciiCapableNumberPad)
                            .autocorrectionDisabled(true)
                            .frame(minWidth: 60)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                DatePicker("Initial Use Date", selection: $lensItem.startDate, displayedComponents: [.date])
            } header: {
                HStack {
                    Image(systemName: "circle.dashed")
                    Text("Main")
                }
            }
    }
}

struct SphereSection: View {
    @Binding var sphere: Sphere
    @State private var lastChangedSide: EyeSide = .both
    @State private var synchronizeValues: Bool = true
    
    var body: some View {
        Section {
            HStack {
                VStack {
                    Text("Left")
                        .bold()
                    Divider()
                    PowerPicker(value: $sphere.left)
                        .onChange(of: sphere.left, { oldValue, newValue in
                            if synchronizeValues, newValue != sphere.right {
                                lastChangedSide = .both
                                withAnimation {
                                    sphere.right = newValue
                                }
                            } else {
                                lastChangedSide = .left
                            }
                        })
                }
                
                Button(action: {
                    withAnimation {
                        self.synchronizeValues.toggle()
                        
                        if self.synchronizeValues {
                            switch lastChangedSide {
                            case .left:
                                sphere.right = sphere.left
                            case .right, .both:
                                sphere.left = sphere.right
                            }
                        }
                    }
                }) {
                    Image(systemName: synchronizeValues ? "link.circle.fill" : "link.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(synchronizeValues ? .teal : .gray)
                }
                .buttonStyle(.plain)
                .padding()
                .padding(.top, 44)
                
                
                VStack {
                    Text("Right")
                        .bold()
                    Divider()
                    PowerPicker(value: $sphere.right)
                        .onChange(of: sphere.right) { oldValue, newValue in
                            if synchronizeValues, newValue != sphere.left {
                                lastChangedSide = .both
                                withAnimation {
                                    sphere.left = newValue
                                }
                            } else {
                                lastChangedSide = .right
                            }
                        }
                }
            }
        } header: {
            HStack {
                Image(systemName: "eyes")
                Text("Sphere")
            }
        }
    }
}

struct DetailSection: View {
    @Binding var detail: LensDetail
    @FocusState var focusField: FocusableField?
    var body: some View {
         Section {
             DetailRow(
                 name: "Base Curve(BC)",
                 predication: "8.0 - 9.5",
                 value: $detail.baseCurve,
                 focusField: _focusField,
                 focusValue: .bc
             )
             DetailRow(
                 name: "Diameter(DIA)",
                 predication: "13.0 - 14.5",
                 value: $detail.dia,
                 focusField: _focusField,
                 focusValue: .dia
             )
             DetailRow(
                 name: "Cylinder Power(PWR)",
                 predication: "-0.75 to -2.75",
                 value: $detail.cylinder,
                 focusField: _focusField,
                 focusValue: .cylinder
             )
             DetailRow(
                name: "Axis Orientation",
                predication: "0 - 180",
                value: $detail.axis,
                focusField: _focusField,
                focusValue: .axis
             )
         } header: {
             HStack {
                 Image(systemName: "slider.horizontal.3")
                 Text("Details (Optional)")
             }
         }
    }
}

struct DetailRow: View {
    var name: String
    var predication: String
    @Binding var value: String
    @FocusState var focusField: FocusableField?
    var focusValue: FocusableField
    var body: some View {
        HStack {
            Text(name)
            Spacer()
            HStack(spacing: 4) {
                TextField(predication, text: $value)
                    .focused($focusField, equals: focusValue)
                    .keyboardType(.decimalPad)
                    .autocorrectionDisabled(true)
                    .multilineTextAlignment(.trailing)
                    .fixedSize()
                    .onReceive([value].publisher.first()) { currentValue in
                        if focusValue == .cylinder {
                            if currentValue == "-" || currentValue.isEmpty {
                                value = ""
                            } else if !currentValue.hasPrefix("-") {
                                value = "-\(currentValue)"
                            }
                        }
                    }
                
                Text(focusValue.unitDescription)
                    .foregroundStyle(Color(.systemGray))
            }
        }
    }
}

#Preview {
    return LensCreateOrEditView(lensItem: .constant(SampleData.content[0]))
}
