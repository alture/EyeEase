//
//  LensCreateOrEditView.swift
//  EE Tracker
//
//  Created by Alisher on 07.12.2023.
//

import SwiftUI
import Combine
import SwiftData

struct LensCreateOrEditView: View {
    let lensItem: LensItem
    @State private var brandName: String = ""
    @State private var wearDuration: WearDuration = .monthly
    @State private var eyeSide: EyeSide = .both
    @State private var initialUseDate: Date = Date.now
    @State private var sphere: Sphere = Sphere()
    @State private var detail: LensDetail = LensDetail()
    @State private var isWearing: Bool = true
    var status: Status = .new
    @FocusState private var focusField: FocusableField?
    @Query private var lensItems: [LensItem]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    enum Status {
        case new
        case edit
        case change
        
        var actionTitle: String {
            switch self {
            case .new:
                return "Add"
            case .edit:
                return "Save"
            case .change:
                return "Change"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                MainSection(
                    focusField: _focusField,
                    brandName: $brandName,
                    wearDuration: $wearDuration,
                    eyeSide: $eyeSide,
                    initialUseDate: $initialUseDate,
                    isWearing: $isWearing
                )
                SphereSection(sphere: $sphere)
                DetailSection(detail: $detail, focusField: _focusField)
            }
            .navigationTitle(status == .new ? "New Lense" : lensItem.name)
            .navigationBarTitleDisplayMode(.inline)
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
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(status.actionTitle) {
                        save()
                        dismiss()
                        switch status {
                        case .new, .change:
                            createNotification(by: lensItem)
                        case .edit:
                            break
                        }
                    }
                    .disabled(brandName.isEmpty)
                }
            }
            .defaultFocus($focusField, .name)
        }
        .onAppear {
            brandName = lensItem.name
            wearDuration = lensItem.wearDuration
            eyeSide = lensItem.eyeSide
            initialUseDate = lensItem.startDate
            sphere = lensItem.sphere
            detail = lensItem.detail
            isWearing = lensItem.isWearing
            
            if status == .change {
                initialUseDate = Date.now
            }
        }
    }
    
    private func save() {
        lensItem.name = brandName
        lensItem.wearDuration = wearDuration
        lensItem.eyeSide = eyeSide
        lensItem.startDate = initialUseDate
        lensItem.sphere = sphere
        lensItem.detail = detail
        
        if !lensItems.contains(where: { $0.isSelected }) {
            lensItem.isSelected = true
        }
        
        if isWearing {
            let wearingLensesDescriptor = FetchDescriptor<LensItem>(predicate: #Predicate { lensItem in
                lensItem.isWearing
            })
            do {
                let result = try modelContext.fetch(wearingLensesDescriptor)
                result.forEach {
                    $0.isWearing = false
                }
            } catch {
                print("Can't fetch lensItems from DataModel")
            }
        }
        
        lensItem.isWearing = isWearing
        modelContext.insert(lensItem)
//        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func createNotification(by item: LensItem) {
        let content = UNMutableNotificationContent()
        content.title = "EyeEase"
        content.body = "\(item.name) will expire today"
        content.sound = UNNotificationSound.default
        
        var dateComponent = DateComponents()
        dateComponent.day = item.remainingDays
        dateComponent.hour = 10
        
        print(dateComponent.description)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
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
    @Binding var brandName: String
    @Binding var wearDuration: WearDuration
    @Binding var eyeSide: EyeSide
    @Binding var initialUseDate: Date
    @Binding var isWearing: Bool
    var body: some View {
        Section {
            LabeledContent("Brand name") {
                TextField("Required", text: $brandName)
                    .autocorrectionDisabled(true)
                    .multilineTextAlignment(.trailing)
                    .focused($focusField, equals: .name)
                    .foregroundStyle(.teal)
                    .submitLabel(.done)
                    .textFieldStyle(.plain)
            }
            Picker("Usage Period", selection: $wearDuration) {
                ForEach(WearDuration.allCases.filter {
                    $0 != .daily && $0 != .yearly
                }) { duration in
                    Text(duration.rawValue)
                        .tag(duration)
                }
            }
            
            Picker("For Which Eye?", selection: $eyeSide) {
                ForEach(EyeSide.allCases) { side in
                    Text(side.rawValue)
                        .tag(side)
                }
            }
            
            //                if wearDuration == .daily {
            //                    HStack {
            //                        Text("Quantity of Lenses")
            //                        Spacer()
            //                        TextField("Required", value: $lensItem.totalNumber, format: .number)
            //                            .keyboardType(.asciiCapableNumberPad)
            //                            .autocorrectionDisabled(true)
            //                            .frame(minWidth: 60)
            //                            .multilineTextAlignment(.trailing)
            //                    }
            //                }
            
            DatePicker("Initial Use Date", selection: $initialUseDate, displayedComponents: [.date])
            
            Toggle("Currently wearing", isOn: $isWearing)
        } header: {
            HStack {
                Image(systemName: "circle.dashed")
                Text("Main")
            }
        } footer: {
            Text("Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum")
        }
    }
}

struct SphereSection: View {
    @Binding var sphere: Sphere
    @State private var lastChangedSide: EyeSide = .both
    
    var body: some View {
        Section {
            HStack {
                VStack {
                    Text("Left")
                        .bold()
                    Divider()
                    PowerPicker(value: $sphere.left)
                        .onChange(of: sphere.left, { oldValue, newValue in
                            if sphere.proportional, newValue != sphere.right {
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
                        self.sphere.proportional.toggle()
                        
                        if self.sphere.proportional {
                            switch lastChangedSide {
                            case .left:
                                sphere.right = sphere.left
                            case .right, .both:
                                sphere.left = sphere.right
                            }
                        }
                    }
                }) {
                    Image(systemName: sphere.proportional ? "link.circle.fill" : "link.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(sphere.proportional ? .teal : .gray)
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
                            if sphere.proportional, newValue != sphere.left {
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
    return LensCreateOrEditView(lensItem: SampleData.content[0])
}
